-- clangd settings for PlatformIO / ESP32 projects.
-- Project include paths come from compile_commands.json (`pio run -t compiledb`).
-- GCC flags that clang rejects are removed in ~/.config/clangd/config.yaml.
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      clangd = {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          -- Arduino.h already includes HardwareSerial.h, esp32-hal-gpio.h and
          -- the rest. Do not add them on completion.
          "--header-insertion=never",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
          -- Let clangd run the ESP32 GCC compilers to get their system include
          -- paths (stdint.h etc.). Without it: "unknown type name 'uint8_t'".
          -- Matches xtensa (ESP32/S2/S3) and riscv (C3/C6/H2) *-elf-gcc/g++.
          -- clangd expands the glob itself, so only ~ is expanded here.
          "--query-driver=" .. vim.fn.expand("~") .. "/.platformio/packages/**/bin/*-elf-g*",
        },
      },
    },
  },
}
