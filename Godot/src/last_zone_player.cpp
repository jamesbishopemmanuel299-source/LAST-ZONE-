#include "last_zone_player.hpp"

#include <godot_cpp/classes/input.hpp>
#include <godot_cpp/classes/input_event_screen_drag.hpp>
#include <godot_cpp/classes/spring_arm3d.hpp>
#include <godot_cpp/classes/viewport.hpp>
#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void LastZonePlayer::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_vehicle_mode", "enabled"), &LastZonePlayer::set_vehicle_mode);
}

void LastZonePlayer::set_vehicle_mode(bool enabled) {
    vehicle_mode = enabled;
}

void LastZonePlayer::_ready() {
    camera_arm = Object::cast_to<SpringArm3D>(
        get_node_or_null(NodePath("SpringArm3D"))
    );
}

void LastZonePlayer::_physics_process(double delta) {
    Input *input = Input::get_singleton();

    const Vector2 stick = input->get_vector(
        "move_left",
        "move_right",
        "move_forward",
        "move_back"
    );

    Vector3 direction(stick.x, 0.0, -stick.y);

    if (camera_arm != nullptr) {
        const Basis camera_basis = camera_arm->get_global_transform().basis;
        Vector3 forward = -camera_basis.get_column(2);
        Vector3 right = camera_basis.get_column(0);
        forward.y = 0.0;
        right.y = 0.0;
        forward = forward.normalized();
        right = right.normalized();
        direction = (right * stick.x) + (forward * -stick.y);
    }

    direction.y = 0.0;
    direction = direction.normalized();

    Vector3 current_velocity = get_velocity();

    if (!is_on_floor()) {
        current_velocity.y -= gravity * delta;
    } else {
        if (current_velocity.y < 0.0) {
            current_velocity.y = 0.0;
        }
        if (input->is_action_just_pressed("jump")) {
            current_velocity.y = jump_velocity;
        }
    }

    const double base_speed = vehicle_mode ? move_speed * 2.35 : move_speed;
    const double active_speed = input->is_action_pressed("sprint")
        ? base_speed * 1.25
        : base_speed;
    current_velocity.x = direction.x * active_speed;
    current_velocity.z = direction.z * active_speed;

    set_velocity(current_velocity);
    move_and_slide();

    if (direction.length_squared() > 0.01) {
        const Vector3 target = get_global_position()
            + Vector3(direction.x, 0.0, direction.z);
        look_at(target, Vector3(0.0, 1.0, 0.0));
    }
}

void LastZonePlayer::_input(const Ref<InputEvent> &event) {
    if (camera_arm == nullptr || event.is_null()) {
        return;
    }

    InputEventScreenDrag *drag =
        Object::cast_to<InputEventScreenDrag>(event.ptr());

    if (drag == nullptr) {
        return;
    }

    const double screen_width = get_viewport()->get_visible_rect().size.x;
    if (drag->get_position().x < screen_width * 0.42) {
        return;
    }

    Vector3 camera_rotation = camera_arm->get_rotation_degrees();
    camera_rotation.y -= drag->get_relative().x * 0.18;
    camera_rotation.x = Math::clamp(
        camera_rotation.x - drag->get_relative().y * 0.12,
        -55.0,
        18.0
    );
    camera_arm->set_rotation_degrees(camera_rotation);
}
