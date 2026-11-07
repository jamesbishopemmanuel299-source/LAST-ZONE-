extends Node
## Lightweight procedural sound effects; no external audio files required.

const RATE := 22050
var enabled := true
var volume := 0.65

func play_ui() -> void:
    _play_tone(720.0, 0.045, 0.22, 0.0)

func play_confirm() -> void:
    _play_tone(520.0, 0.10, 0.28, 0.0)

func play_shot() -> void:
    _play_noise_tone(105.0, 0.105, 0.34)

func play_reload() -> void:
    _play_tone(330.0, 0.12, 0.24, 0.0)
    get_tree().create_timer(0.14).timeout.connect(func(): _play_tone(470.0, 0.10, 0.22, 0.0))

func play_hit() -> void:
    _play_tone(920.0, 0.075, 0.25, 0.0)

func play_empty() -> void:
    _play_tone(180.0, 0.055, 0.18, 0.0)

func set_enabled(value: bool) -> void:
    enabled = value

func set_volume(value: float) -> void:
    volume = clampf(value, 0.0, 1.0)

func _play_tone(frequency: float, duration: float, amplitude: float, noise_mix: float) -> void:
    if not enabled:
        return
    var frames := maxi(1, int(RATE * duration))
    var bytes := PackedByteArray()
    bytes.resize(frames * 2)
    for i in range(frames):
        var t := float(i) / RATE
        var envelope := minf(1.0, float(i) / 90.0) * pow(1.0 - float(i) / frames, 2.0)
        var wave := sin(TAU * frequency * t)
        wave = lerpf(wave, randf_range(-1.0, 1.0), noise_mix)
        var sample := int(clampf(wave * envelope * amplitude * volume, -1.0, 1.0) * 32767.0)
        bytes.encode_s16(i * 2, sample)
    var stream := AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = RATE
    stream.stereo = false
    stream.data = bytes
    var player := AudioStreamPlayer.new()
    player.stream = stream
    player.volume_db = 0.0
    add_child(player)
    player.finished.connect(player.queue_free)
    player.play()

func _play_noise_tone(frequency: float, duration: float, amplitude: float) -> void:
    _play_tone(frequency, duration, amplitude, 0.72)
