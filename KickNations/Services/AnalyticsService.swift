import Foundation

enum AnalyticsEvent: String {
    case appFirstOpen = "app_first_open"
    case tutorialFirstLaunch = "tutorial_first_launch"
    case firstGoalScored = "first_goal_scored"
    case matchStarted = "match_started"
    case matchCompleted = "match_completed"
    case skillUsed = "skill_used"
    case highlightGenerated = "highlight_generated"
    case highlightShared = "highlight_shared"
    case dailyClashStarted = "daily_clash_started"
    case roastReplayGenerated = "roast_replay_generated"
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

