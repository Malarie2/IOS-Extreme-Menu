#ifndef STRUCTS_H
#define STRUCTS_H


//  struct FName
//     {
//         std::int32_t comparison_index;
//         std::int32_t number;
//     };


//  struct fstring : tarray<wchar_t>
//     {};

struct Vector3 {
    float X;
    float Y;
    float Z;

    Vector3() : X(0), Y(0), Z(0) {}
    Vector3(float _x, float _y, float _z) : X(_x), Y(_y), Z(_z) {}

    Vector3 operator *(const Vector3 Factor) {
        return {X * Factor.X, Y * Factor.Y, Z * Factor.Z};
    }

    Vector3 operator /(const Vector3 Divider) {
        return {X / Divider.X, Y / Divider.Y, Z / Divider.Z};
    }

    Vector3 operator +(const Vector3 Additor) {
       return {X + Additor.X, Y + Additor.Y, Z + Additor.Z};
    }

    Vector3 operator -(const Vector3 Subtractor) {
       return {X - Subtractor.X, Y - Subtractor.Y, Z - Subtractor.Z};
    }

    Vector3 operator -() const {
        return {-X, -Y, -Z};
    }

    Vector3 operator *(const float Factor) {
        return {X * Factor, Y * Factor, Z * Factor};
    }

    Vector3 operator /(const float Divider) {
        return {X / Divider, Y / Divider, Z / Divider};
    }

    float Dot(const Vector3 VectorB) {
        return X * VectorB.X + Y * VectorB.Y + Z * VectorB.Z;
    }

    float Distance(const Vector3 VectorB) {
        Vector3 VectorDelta = *this - VectorB;
        return sqrtf(VectorDelta.Dot(VectorDelta));
    }
};

struct ViewMatrix {
    float Matrix[4][4];
};

#endif /* STRUCTS_H */