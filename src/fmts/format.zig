const std = @import("std");

pub fn auto(comptime T: type) []const u8 {
    comptime var result: []const u8 = "." ++ @typeName(T) ++ " {{\n";
    inline for (std.meta.fields(T)) |field| {
        const field_fmt = comptime fmt_by_type(field.type);
        result = result ++
            "    ." ++ field.name ++
            " = " ++ field_fmt ++
            ",\n";
    }
    result = result ++ "}}\n";
    return result;
}

fn fmt_by_type(comptime T: type) []const u8 {
    if (T == []const u8 or T == []u8) {
        return "{s}";
    }
    return switch (@typeInfo(T)) {
        .int, .comptime_int, .float, .comptime_float => "{d}",
        .bool => "{}",
        .@"enum" => "{}",
        .pointer => "{*}",
        else => "{any}",
    };
}

const Container = enum {
    GlassBottle,
    AluminiumCan,
};
const Drink = struct {
    name: []const u8,
    volume: f16,
    alcohol: bool,
    container: Container,
};

test "builds auto format correctly" {
    const expected_format =
        \\.format.Drink {{
        \\    .name = {s},
        \\    .volume = {d},
        \\    .alcohol = {},
        \\    .container = {},
        \\}}
        \\
    ;
    const beer = Drink{ .name = "Beer", .volume = 0.5, .container = .GlassBottle, .alcohol = true };
    std.log.info(
        auto(Drink),
        beer,
    );
    try std.testing.expectEqualStrings(expected_format, auto(Drink));
}

test "correctly picks format by type" {
    const enum_t = enum { one, two };
    const struct_t = struct { name: []const u8 };
    const pointer_t = &enum_t.one;
    const cases = .{
        TestCase(type, []const u8){ .input = i32, .expected = "{d}" },
        TestCase(type, []const u8){ .input = i64, .expected = "{d}" },
        TestCase(type, []const u8){ .input = f128, .expected = "{d}" },
        TestCase(type, []const u8){ .input = bool, .expected = "{}" },
        TestCase(type, []const u8){ .input = struct_t, .expected = "{any}" },
        TestCase(type, []const u8){ .input = enum_t, .expected = "{}" },
        TestCase(type, []const u8){ .input = @TypeOf(pointer_t), .expected = "{*}" },
    };
    inline for (cases) |case| {
        try std.testing.expectEqualStrings(
            case.expected,
            fmt_by_type(case.input),
        );
    }
}

fn TestCase(comptime I: type, comptime E: type) type {
    return struct {
        input: I,
        expected: E,
    };
}
