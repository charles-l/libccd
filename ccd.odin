// build +linux
package ccd

import c "core:c/libc"
import "core:os"
import "core:fmt"
import "core:mem"
import "core:strings"
import "core:math/linalg"

// configured to use f32, so build lib with USE_SINGLE=yes
Real :: f32
Vector3 :: linalg.Vector3f32

when os.OS == .Linux do foreign import lib "libccd/src/libccd.a";

SupportFn :: #type proc "c" (obj: rawptr, dir: ^Vector3, vec: ^Vector3)
FirstDirFn :: #type proc "c" (obj1: rawptr, obj2: rawptr, dir: ^Vector3)
CenterFn :: #type proc "c" (obj1: rawptr, center: ^Vector3)

CCD :: struct {
    first_dir: FirstDirFn,
    support1: SupportFn,
    support2: SupportFn,
    center1: CenterFn,
    center2: CenterFn,

    max_iterations: c.ulong,
    epa_tolerance: Real,
    mpr_tolerance: Real,
    dist_tolerance: Real,
}


@(default_calling_convention="c")
foreign lib {
    @(link_name="ccdFirstDirDefault") first_dir_default :: proc(obj1: rawptr, obj2: rawptr, dir: ^Vector3) ---
    @(link_name="ccdGJKIntersect") gjk_intersect :: proc(obj1: rawptr, obj2: rawptr, ccd: ^CCD) -> c.int ---
    @(link_name="ccdGJKSeparate") gjk_separate :: proc(obj1: rawptr, obj2: rawptr, ccd: ^CCD, sep: ^Vector3) -> c.int ---
    @(link_name="ccdGJKPenetration") gjk_penetration :: proc(obj1: rawptr, obj2: rawptr, ccd: ^CCD, depth: ^Real, dir, pos: ^Vector3) -> c.int ---
    @(link_name="ccdMPRIntersect") mpr_intersect :: proc(obj1: rawptr, obj2: rawptr, ccd: ^CCD) -> c.int ---
    @(link_name="ccdMPRPenetration") mpr_penetration :: proc(obj1: rawptr, obj2: rawptr, ccd: ^CCD, depth: ^Real, dir, pos: ^Vector3) -> c.int ---
}

make_ccd :: proc(support1: SupportFn, support2: SupportFn) -> CCD {
    ccd := CCD{
        first_dir = first_dir_default,
        support1 = support1,
        support2 = support2,
        max_iterations = 512,
        epa_tolerance = 0.0001,
        mpr_tolerance = 0.0001,
        dist_tolerance = 0.000001,
    }
    return ccd
}
