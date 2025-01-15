pub const Default = struct {
    top_left: []const u8 = "┌",
    top_right: []const u8 = "┐",
    top_column: []const u8 = "┬",
    bottom_left: []const u8 = "└",
    bottom_right: []const u8 = "┘",
    bottom_column: []const u8 = "┴",
    middle_left: []const u8 = "├",
    middle_right: []const u8 = "┤",
    middle_column: []const u8 = "┼",
    horizontal: []const u8 = "─",
    vertical: []const u8 = "│",
};

pub const Rounded = Default{
    .top_left = "╭",
    .top_right = "╮",
    .bottom_left = "╰",
    .bottom_right = "╯",
};

pub const Markdown = Default{
    .top_left = "-",
    .top_right = "-",
    .top_column = "-",
    .bottom_left = "-",
    .bottom_right = "-",
    .bottom_column = "-",
    .middle_left = "|",
    .middle_right = "|",
    .middle_column = "|",
    .horizontal = "-",
    .vertical = "|",
};
