import Foundation

enum AnalyticsEvent: String {
    case appFirstOpen = "app_first_open"
    case tutorialFirstLaunch = "tutorial_first_launch"
    case firstGoalScored = "first_goal_scored"
    case cupMatchStarted = "cup_match_started"
    case cupMatchCompleted = "cup_match_completed"
    case practiceStarted = "practice_started"
    case practiceCompleted = "practice_completed"
    case skillUsed = "skill_used"
    case highlightGenerated = "highlight_generated"
    case highlightShared = "highlight_shared"
    case iapViewed = "iap_viewed"
    case iapPurchased = "iap_purchased"
    case rewardedAdStarted = "rewarded_ad_started"
    case rewardedAdCompleted = "rewarded_ad_completed"
}

struct AnalyticsService {
    func track(_ event: AnalyticsEvent, properties: [String: String] = [:]) {
        #if DEBUG
        print("Analytics:", event.rawValue, properties)
        #endif
    }
}
