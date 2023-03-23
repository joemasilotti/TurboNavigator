public enum Navigation {
    public enum Context: String {
        case `default`
        case modal
    }

    public enum Presentation: String {
        case `default`
        case pop
        case replace
        case refresh
        case clearAll = "clear_all"
        case replaceRoot = "replace_root"
    }

    public enum Modal: String {
        case `default`
        case fullScreen = "full_screen"
    }
}
