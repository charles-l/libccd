package main
import "core:fmt"
import "core:runtime"
import "core:math/linalg"
import "../../libccd"
import "vendor:raylib"

rl :: raylib

RADIUS :: 1

support_sphere :: proc "c" (pos: rawptr, d: ^libccd.Vector3, out: ^libccd.Vector3) {
    context = runtime.default_context()
    p := cast(^libccd.Vector3) pos
    dir := linalg.normalize(d^) * RADIUS
    out^ = p^ + dir
    rl.DrawSphere(out^, 0.1, rl.PURPLE)
}

main :: proc() {
    rl.InitWindow(800, 600, "libccd demo")
    rl.SetTargetFPS(60)

    camera := rl.Camera3D{};
    camera.position = rl.Vector3{10, 10, 10};
    camera.target = rl.Vector3{};
    camera.up = rl.Vector3{0, 1, 0};
    camera.fovy = 45;
    camera.projection = .PERSPECTIVE;

    rl.SetCameraMode(camera, .FREE);

    ccd := libccd.make_ccd(support_sphere, support_sphere)
    a := libccd.Vector3{}
    b := libccd.Vector3{4, 0, 0}

    for !rl.WindowShouldClose() {
        rl.UpdateCamera(&camera);

        if rl.IsKeyDown(.LEFT) { a.z += 0.1 }
        if rl.IsKeyDown(.RIGHT) { a.z -= 0.1 }
        if rl.IsKeyDown(.UP) { a.x -= 0.1 }
        if rl.IsKeyDown(.DOWN) { a.x += 0.1 }

        rl.BeginDrawing()
        defer rl.EndDrawing();

        rl.ClearBackground(rl.RAYWHITE)

        rl.BeginMode3D(camera);
            rl.DrawGrid(10, 1.0);
            rl.DrawSphereWires(a, RADIUS, 8, 16, rl.GREEN);
            rl.DrawSphereWires(b, RADIUS, 8, 16, rl.BLUE);
            colliding := libccd.gjk_intersect(&a, &b, &ccd)
        rl.EndMode3D();

        rl.DrawText("Purple dots show support points, arrow keys move green sphere", 10, 10, 20, rl.BLACK)
        if colliding == 1 {
            rl.DrawText("Colliding", 10, 40, 20, rl.RED)
        }
    }
}
