#pragma once

#include <godot_cpp/classes/character_body3d.hpp>
#include <godot_cpp/classes/ref.hpp>

namespace godot {

class InputEvent;
class SpringArm3D;

class LastZonePlayer : public CharacterBody3D {
    GDCLASS(LastZonePlayer, CharacterBody3D)

private:
    double move_speed = 6.5;
    double gravity = 9.8;
    double jump_velocity = 5.2;
    SpringArm3D *camera_arm = nullptr;

protected:
    static void _bind_methods();

public:
    void _ready() override;
    void _physics_process(double delta) override;
    void _input(const Ref<InputEvent> &event) override;
};

} // namespace godot
