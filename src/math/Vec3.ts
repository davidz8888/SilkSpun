// src/math/Vec3.ts

export class Vec3 {
    x: number;
    y: number;
    z: number;

    constructor(x = 0, y = 0, z = 0) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    clone(): Vec3 {
        return new Vec3(this.x, this.y, this.z);
    }

    set(x: number, y: number, z: number): this {
        this.x = x;
        this.y = y;
        this.z = z;
        return this;
    }

    add(v: Vec3): this {
        this.x += v.x;
        this.y += v.y;
        this.z += v.z;
        return this;
    }

    sub(v: Vec3): this {
        this.x -= v.x;
        this.y -= v.y;
        this.z -= v.z;
        return this;
    }

    scale(s: number): this {
        this.x *= s;
        this.y *= s;
        this.z *= s;
        return this;
    }

    length(): number {
        return Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
    }

    normalize(): this {
        const len = this.length();
        if (len > 0) this.scale(1 / len);
        return this;
    }

    dot(v: Vec3): number {
        return this.x * v.x + this.y * v.y + this.z * v.z;
    }

    cross(v: Vec3): Vec3 {
        return new Vec3(
            this.y * v.z - this.z * v.y,
            this.z * v.x - this.x * v.z,
            this.x * v.y - this.y * v.x
        );
    }

    lerp(to: Vec3, t: number): this {
        this.x += (to.x - this.x) * t;
        this.y += (to.y - this.y) * t;
        this.z += (to.z - this.z) * t;
        return this;
    }

    equals(v: Vec3): boolean {
        return this.x === v.x && this.y === v.y && this.z === v.z;
    }

    toArray(): [number, number, number] {
        return [this.x, this.y, this.z];
    }

    static fromArray(arr: [number, number, number]): Vec3 {
        return new Vec3(arr[0], arr[1], arr[2]);
    }

    static lerp(a: Vec3, b: Vec3, t: number): Vec3 {
        return new Vec3(
            a.x + (b.x - a.x) * t,
            a.y + (b.y - a.y) * t,
            a.z + (b.z - a.z) * t
        );
    }
}
