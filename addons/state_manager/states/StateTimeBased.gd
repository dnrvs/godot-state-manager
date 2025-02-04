extends OldState
class_name StateTimeBase

""" This state is made to be the base of other time-based states """

var _timer: Timer = Timer.new()

func _init() -> void:
	_timer.one_shot = true

func _ready() -> void:
	if not Engine.is_editor_hint():
		add_child(_timer)
		_timer.timeout.connect(_on_timer_timeout)

func start() -> void:
	super()
	_timer.start()
func stop() -> void:
	super()
	_timer.stop()

func set_wait_time(wait_time: float) -> void:
	_timer.wait_time = wait_time
func get_time_left() -> float:
	return _timer.time_left
func get_wait_time() -> float:
	return _timer.wait_time

func _on_timer_timeout() -> void:
	_finish_state()
