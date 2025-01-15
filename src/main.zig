const std = @import("std");
const t = @import("root.zig");

pub fn main() !void {
    const MyEnum = enum { one, two, three, four, five };
    const Book = struct {
        release_date: []const u8,
        title: []const u8,
        author: []const u8,
        cost: []const u8,
        purchased: []const u8 = "true",
        num: bool = false,
    };
    const books = [_]Book{
        .{
            .release_date = "December 20, 2014",
            .title = "The Hobbit of the Universe",
            .author = "Andrew Karpathy",
            .cost = "120.40",
        },
        .{
            .release_date = "December 12, 2014",
            .title = "The King of the Jungle",
            .author = "S. Sultanchand",
            .cost = "421.99",
            .purchased = "false",
        },
        .{
            .release_date = "December 21, 2005",
            .title = "Multiverse of Madness: Unscripted",
            .author = "J. K. Rowling",
            .cost = "231.99",
        },
        .{
            .release_date = "December 13, 2017",
            .title = "Jungle King: The Holy Grail",
            .author = "Mark Robert",
            .cost = "125.79",
        },
    };
    _ = books; // autofix
    const names = [_][]const u8{ "John Doe", "Andrew Karpathy", "Carl Schwabb", "Mark Robert" };
    _ = names; // autofix
    const types = [_]MyEnum{ .five, .one, .two };
    try t.printTable(types, .{
        .allocator = std.heap.c_allocator,
    });
}
