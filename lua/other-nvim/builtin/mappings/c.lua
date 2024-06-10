return {
    {
        -- context = "C header",
        pattern = "(.*).c$",
        target = "%1.h",
    },
    {
        -- context = "C source file",
        pattern = "(.*).h$",
        target = "%1.c",
    },
    {
        -- context = "C header",
        pattern = "(.*).cpp$",
        target = "%1.hpp",
    },
    {
        -- context = "C source file",
        pattern = "(.*).hpp$",
        target = "%1.cpp",
    },
}
