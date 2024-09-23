//
//  StoryViewController.swift
//  InstagramStory
//
//  Created by Otis on 2024/9/23.
//

import UIKit

class StoryViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var stories: [Story] = []
    let storyService = StoryService()
    
    init() {
            super.init(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        fetchAndDisplayStories()
    }
    
    func fetchAndDisplayStories() {
        storyService.fetchStories { [weak self] stories in
            self?.stories = stories
            if let firstStory = self?.storyViewController(for: 0) {
                self?.setViewControllers([firstStory], direction: .forward, animated: true, completion: nil)
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? StoryContentViewController else { return nil }
        let index = currentVC.index
        return storyViewController(for: index - 1)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? StoryContentViewController else { return nil }
        let index = currentVC.index
        return storyViewController(for: index + 1)
    }
    
    func storyViewController(for index: Int) -> StoryContentViewController? {
        guard index >= 0 && index < stories.count else { return nil }
        let storyContentVC = StoryContentViewController()
        storyContentVC.story = stories[index]
        storyContentVC.index = index
        return storyContentVC
    }
    
    // 前往下一個 Story
    func moveToNextStory() {
        guard let currentVC = viewControllers?.first as? StoryContentViewController else { return }
        let nextIndex = currentVC.index + 1
        if let nextVC = storyViewController(for: nextIndex) {
            setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    // 回到前一個 Story
    func moveToPreviousStory() {
        guard let currentVC = viewControllers?.first as? StoryContentViewController else { return }
        let previousIndex = currentVC.index - 1
        if let previousVC = storyViewController(for: previousIndex) {
            setViewControllers([previousVC], direction: .reverse, animated: true, completion: nil)
        }
    }
}
