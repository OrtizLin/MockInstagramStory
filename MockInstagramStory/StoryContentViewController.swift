//
//  StoryContentViewController.swift
//  InstagramStory
//
//  Created by Otis on 2024/9/23.
//

import UIKit
import AVKit

class StoryContentViewController: UIViewController {
    
    var story: Story?
    var index: Int = 0
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var progressView: UIProgressView!
    var timer: Timer?
    var currentProgress: Float = 0.0
    var maxDuration: Int = 5
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        setupProgressView()
        setupContent()
        setupGestureRecognizers()
    }
    
    func setupProgressView() {
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = .white
        progressView.trackTintColor = .gray
        progressView.frame = CGRect(x: 0, y: 50, width: view.frame.width, height: 2)
        progressView.setProgress(0, animated: false)
        view.addSubview(progressView)
    }
    
    func setupContent() {
        guard let story = story else { return }
        maxDuration = story.duration
        
        if story.mediaType == "video" {
            setupVideoPlayer(urlString: story.mediaUrl)
        } else if story.mediaType == "image" {
            setupImageView(urlString: story.mediaUrl)
        }
        
        // 啟動進度條的計時器
        startProgressTimer()
    }
    
    func setupImageView(urlString: String) {
        view.addSubview(imageView)
        imageView.frame = view.bounds
        if let url = URL(string: urlString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
        }
    }
    
    func setupVideoPlayer(urlString: String) {
        if let url = URL(string: urlString) {
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = view.bounds
            if let playerLayer = playerLayer {
                view.layer.addSublayer(playerLayer)
            }
            player?.play()
        }
    }
    
    func startProgressTimer() {
        timer?.invalidate() // 先取消任何現存的計時器
        currentProgress = 0.0
        progressView.setProgress(currentProgress, animated: false)
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.currentProgress += 0.05 / Float(self.maxDuration)
            self.progressView.setProgress(self.currentProgress, animated: true)
            
            if self.currentProgress >= 1.0 {
                timer.invalidate()
                self.notifyStoryCompletion()
            }
        }
    }
    
    func notifyStoryCompletion() {
        // 進度條到了，自動切換到下一個 Story
        if let parentVC = self.parent as? StoryViewController {
            parentVC.moveToNextStory()
        }
    }
    
    func setupGestureRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: view)
        
        if touchPoint.x < view.frame.width / 2 {
            // 往左拉到前一個 Story
            if let parentVC = self.parent as? StoryViewController {
                parentVC.moveToPreviousStory()
            }
        } else {
            // 往右拉到下一個 Story
            if let parentVC = self.parent as? StoryViewController {
                parentVC.moveToNextStory()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
        timer?.invalidate()
    }
}

