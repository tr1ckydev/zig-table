const std = @import("std");
pub const Style = @import("styles.zig");
const Utils = @import("utils.zig");

const Cell = []const u8;

const Config = struct {
    allocator: std.mem.Allocator,
    html: bool = false,
    style: Style.Default = .{},
    index: bool = true,
    header: bool = true,
    transpose: bool = false,

    // Design
    alignment: Utils.Align = .Center,
    border: bool = true,
    header_line: bool = true,
    row_line: bool = true,
    column_line: bool = true,

    // Macro
    macro: ?*const fn (anytype) anyerror!void = null,
};

pub fn printTable(data: anytype, comptime config: Config) !void {
    switch (@typeInfo(@TypeOf(data))) {
        .array => |a| switch (@typeInfo(a.child)) {
            .@"struct" => |s| {
                const row_count = data.len + @intFromBool(config.header);
                const col_count = s.fields.len + @intFromBool(config.index);
                var table = Utils.StaticArrayList([col_count]Cell, row_count){};
                if (config.header) {
                    var row = Utils.StaticArrayList(Cell, col_count){};
                    if (config.index) row.push("(index)");
                    inline for (s.fields) |field| row.push(field.name);
                    table.push(row.arr);
                }
                inline for (data, 0..) |e, i| {
                    var row = Utils.StaticArrayList(Cell, col_count){};
                    if (config.index) row.push(std.fmt.comptimePrint("{}", .{i}));
                    inline for (s.fields) |field| row.push(try toString(config.allocator, @field(e, field.name)));
                    table.push(row.arr);
                }
                try writeTable(&table.arr, config);
            },
            else => {
                const row_count = data.len + @intFromBool(config.header);
                const col_count = if (config.index) 2 else 1;
                var table = Utils.StaticArrayList([col_count]Cell, row_count){};
                if (config.header) {
                    var row = Utils.StaticArrayList(Cell, col_count){};
                    if (config.index) row.push("(index)");
                    row.push(@typeName(a.child));
                    table.push(row.arr);
                }
                inline for (data, 0..) |e, i| {
                    var row = Utils.StaticArrayList(Cell, col_count){};
                    if (config.index) row.push(std.fmt.comptimePrint("{}", .{i}));
                    row.push(try toString(config.allocator, e));
                    table.push(row.arr);
                }
                try writeTable(&table.arr, config);
            },
        },
        .@"struct" => |s| {
            const row_count = s.fields.len + @intFromBool(config.header);
            const col_count = if (config.index) 2 else 1;
            var table = Utils.StaticArrayList([col_count]Cell, row_count){};
            if (config.header) {
                var row = Utils.StaticArrayList(Cell, col_count){};
                if (config.index) row.push("(index)");
                row.push("Value");
                table.push(row.arr);
            }
            inline for (s.fields) |f| {
                var row = Utils.StaticArrayList(Cell, col_count){};
                if (config.index) row.push(f.name);
                row.push(try toString(config.allocator, @field(data, f.name)));
                table.push(row.arr);
            }
            try writeTable(&table.arr, config);
        },
        else => |o| @compileError("not implemented: " ++ @tagName(o)),
    }
}

fn writeTable(table: anytype, comptime config: Config) !void {
    if (config.macro) |m| try m(table);
    const t = if (config.transpose) Utils.transpose(table) else table;
    var bw = std.io.bufferedWriter(std.io.getStdOut().writer());
    const w = bw.writer();

    if (config.html) {
        try w.writeAll("<table>\n");
        for (t) |row| {
            try w.writeAll("  <tr>\n");
            for (row) |cell| {
                try w.writeAll("    <td>");
                try w.writeAll(cell);
                try w.writeAll("</td>\n");
            }
            try w.writeAll("  </tr>\n");
        }
        try w.writeAll("</table>\n");
        try bw.flush();
        return;
    }

    var lens = [_]usize{0} ** if (config.transpose) table.len else Utils.childLen(@TypeOf(table.*));
    for (t) |row| {
        for (row, 0..) |cell, i| lens[i] = @max(cell.len, lens[i]);
    }

    if (config.border) {
        _ = try w.write(config.style.top_left);
        for (lens, 0..) |len, i| {
            try w.writeBytesNTimes(config.style.horizontal, len + 2);
            if (config.column_line and i != lens.len - 1) _ = try w.write(config.style.top_column);
        }
        _ = try w.write(config.style.top_right);
        try w.writeByte('\n');
    }

    for (t, 0..) |row, i| {
        if (config.border) _ = try w.write(config.style.vertical);
        for (row, lens, 0..) |cell, len, j| {
            try Utils.writeAlign(w, cell, len, config.alignment);
            if (config.column_line and j != row.len - 1) _ = try w.write(config.style.vertical);
        }
        if (config.border) _ = try w.write(config.style.vertical);
        try w.writeByte('\n');
        if (config.row_line and i != t.len - 1) {
            if (config.border) _ = try w.write(config.style.middle_left);
            for (lens, 0..) |len, j| {
                try w.writeBytesNTimes(config.style.horizontal, len + 2);
                if (config.column_line and j != lens.len - 1) _ = try w.write(config.style.middle_column);
            }
            if (config.border) _ = try w.write(config.style.middle_right);
            try w.writeByte('\n');
        }
    }

    if (config.border) {
        _ = try w.write(config.style.bottom_left);
        for (lens, 0..) |len, i| {
            try w.writeBytesNTimes(config.style.horizontal, len + 2);
            if (config.column_line and i != lens.len - 1) _ = try w.write(config.style.bottom_column);
        }
        _ = try w.write(config.style.bottom_right);
        try w.writeByte('\n');
    }
    try bw.flush();
}

fn toString(allocator: std.mem.Allocator, data: anytype) ![]const u8 {
    switch (@typeInfo(@TypeOf(data))) {
        .int, .float => return try std.fmt.allocPrint(allocator, "{}", .{data}),
        .bool => return if (data) "true" else "false",
        .type => return @typeName(data),
        .@"enum" => return @tagName(data),
        else => return data,
    }
}
