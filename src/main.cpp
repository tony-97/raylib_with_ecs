#include <raylib.h>

auto
main() -> int
{
  InitWindow(640, 480, "Window");
  SetTargetFPS(60000);
  while (not WindowShouldClose()) {
    BeginDrawing();
    ClearBackground(RAYWHITE);
    DrawFPS(10, 10);
    EndDrawing();
  }
  CloseWindow();
  return 0;
}
