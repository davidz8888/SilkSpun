// src/math/Vec2.ts

export class Vec2 {
    x: number;
    y: number;

    constructor(x = 0, y = 0) {
        this.x = x;
        this.y = y;
    }

    clone(): Vec2 {
        return new Vec2(this.x, this.y);
    }

    set(x: number, y: number): this {
        this.x = x;
        this.y = y;
        return this;
    }

    add(v: Vec2): this {
        this.x += v.x;
        this.y += v.y;
        return this;
    }

    sub(v: Vec2): this {
        this.x -= v.x;
        this.y -= v.y;
        return this;
    }

    scale(s: number): this {
        this.x *= s;
        this.y *= s;
        return this;
    }

    length(): number {
        return Math.sqrt(this.x * this.x + this.y * this.y);
    }

    normalize(): this {
        const len = this.length();
        if (len > 0) this.scale(1 / len);
        return this;
    }

    dot(v: Vec2): number {
        return this.x * v.x + this.y * v.y;
    }

    cross(v: Vec2): Vec2 {
        return new Vec2(
            this.x * v.y - this.y * v.x,
        );
    }

    lerp(to: Vec2, t: number): this {
        this.x += (to.x - this.x) * t;
        this.y += (to.y - this.y) * t;
        return this;
    }

    equals(v: Vec2): boolean {
        return this.x === v.x && this.y === v.y;
    }

    toArray(): [number, number] {
        return [this.x, this.y];
    }

    static fromArray(arr: [number, number, number]): Vec2 {
        return new Vec2(arr[0], arr[1]);
    }

    static lerp(a: Vec2, b: Vec2, t: number): Vec2 {
        return new Vec2(
            a.x + (b.x - a.x) * t,
            a.y + (b.y - a.y) * t,
        );
    }
}
