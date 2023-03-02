enum Navigation {
    enum Context: String {
        case `default`
        case modal
    }

    enum Presentation: String {
        case `default`
        case pop
        case replace
        case refresh
        case clearAll = "clear_all"
        case replaceRoot = "replace_root"
    }
}
