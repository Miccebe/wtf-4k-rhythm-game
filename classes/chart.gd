class_name Chart

var chart: Array[ChartElement] = []

enum Track {
	TRACK_1 = 1,
	TRACK_2 = 2,
	TRACK_3 = 3,
	TRACK_4 = 4,
}

const BPM_MATCH_PATTERN: String = r"(?<=\()\-?\d+\.?(\d+)?(?=\))"
const NOTE_TIME_MATCH_PATTERN: String = r"(?<=\{)\d+(?=\})"
const EMPTY_NOTE_MATCH_PATTERN: String = r"(?<=[)},/])(?=,)"
const TAP_NOTE_MATCH_PATTERN: String = r"(?<=[)},/])[1-4](?=[,/])"
const CATCH_NOTE_MATCH_PATTERN: String = r"(?<=[)},/])[1-4]c(?=[,/])"
const HOLD_NOTE_MATCH_PATTERN: String = r"(?<=[)},/])[1-4]h\[\d+:\d+](?=[,/])"
const EACH_NOTE_MATCH_PATTERN: String = r"(?<=[)},])([0-9ch\[:\]]*/)+[0-9ch\[:\]]*,"


func load_chart(_chart_content_text: String) -> Error:
	self.chart = []
	var chart_content_text: String = _chart_content_text.strip_escapes().replace(' ',"")
	print("Loading Chart: chart_content_text = ", chart_content_text)
	# 读取各个note匹配信息
	var match_pattern: RegEx = RegEx.new()
	match_pattern.compile(Chart.BPM_MATCH_PATTERN)
	var bpm_match_result: Array[RegExMatch] = match_pattern.search_all(chart_content_text)
	if bpm_match_result.is_empty():
		print("Load Error: Empty BPM List")
		return ERR_INVALID_PARAMETER
	match_pattern.compile(Chart.NOTE_TIME_MATCH_PATTERN)
	var note_time_match_result: Array[RegExMatch] = match_pattern.search_all(chart_content_text)
	if note_time_match_result.is_empty():
		print("Load Error: Empty Note Time List")
		return ERR_INVALID_PARAMETER
	match_pattern.compile(Chart.EMPTY_NOTE_MATCH_PATTERN)
	var empty_note_match_result: Array[RegExMatch] = match_pattern.search_all(chart_content_text)
	match_pattern.compile(Chart.TAP_NOTE_MATCH_PATTERN)
	var tap_note_match_result: Array[RegExMatch] = match_pattern.search_all(chart_content_text)
	match_pattern.compile(Chart.CATCH_NOTE_MATCH_PATTERN)
	var catch_note_match_result: Array[RegExMatch] = match_pattern.search_all(chart_content_text)
	match_pattern.compile(Chart.HOLD_NOTE_MATCH_PATTERN)
	var hold_note_match_result: Array[RegExMatch] = match_pattern.search_all(chart_content_text)
	match_pattern.compile(Chart.EACH_NOTE_MATCH_PATTERN)
	var each_note_match_result: Array[RegExMatch] = match_pattern.search_all(chart_content_text)
	# 把匹配结果加入到列表中，然后按照匹配字符串开始位置排序
	var chart_content_list: Array[Array] = []
	for i in bpm_match_result:
		chart_content_list.append(["BPM", i.get_string(), i.get_start()])
	for i in note_time_match_result:
		chart_content_list.append(["NoteTime", i.get_string(), i.get_start()])
	for i in empty_note_match_result:
		chart_content_list.append(["EmptyNote", i.get_string(), i.get_start()])
	for i in tap_note_match_result:
		chart_content_list.append(["TapNote", i.get_string(), i.get_start()])
	for i in catch_note_match_result:
		chart_content_list.append(["CatchNote", i.get_string(), i.get_start()])
	for i in hold_note_match_result:
		chart_content_list.append(["HoldNote", i.get_string(), i.get_start()])
	for i in each_note_match_result:
		chart_content_list.append(["EachNote", i.get_string(), i.get_start()])
	chart_content_list.sort_custom(func(a, b): return a[-1] < b[-1])
	# 把标记了字符串信息的列表转成ChartElement列表
	var chart_content: Array[ChartElement] = []
	var each_note_temp: Array[Note]
	var each_note_content_count: int = 0
	for i in range(len(chart_content_list)):
		if chart_content_list[i][0] == "BPM":
			chart_content.append(BPM.new(chart_content_list[i][1], i))
		elif chart_content_list[i][0] == "NoteTime":
			chart_content.append(NoteTime.new(chart_content_list[i][1], i))
		elif chart_content_list[i][0] == "EmptyNote":
			chart_content.append(EmptyNote.new(chart_content_list[i][1], i))
		elif chart_content_list[i][0] == "TapNote":
			chart_content.append(TapNote.new(chart_content_list[i][1], 1))
		elif chart_content_list[i][0] == "CatchNote":
			chart_content.append(CatchNote.new(chart_content_list[i][1], 1))
		elif chart_content_list[i][0] == "HoldNote":
			chart_content.append(HoldNote.new(chart_content_list[i][1], 1))
		elif chart_content_list[i][0] == "EachNote":
			each_note_temp = EachNote.new(chart_content_list[i][1], 1).note_list
			each_note_content_count += len(each_note_temp)
			if each_note_temp != []:
				chart_content.append(each_note_temp)
	if len(tap_note_match_result) + len(catch_note_match_result) + len(hold_note_match_result) + each_note_content_count < 1:
		print("Load Error: Empty Note List")
		return ERR_INVALID_PARAMETER
	self.chart = chart_content
	return OK


func load_chart_from_reference(_reference: BaseChartDirReference) -> Error:
	var chart_file: FileAccess = FileAccess.open(_reference.chart_file_path, FileAccess.READ)
	if FileAccess.get_open_error():
		return FileAccess.get_open_error()
	var chart_content: String = chart_file.get_as_text()
	var chart_content_list: PackedStringArray = chart_content.split("\n")
	var new_chart_content_list: PackedStringArray = []
	for i in chart_content_list:
		if not (i.is_empty() or i[0] == '$'):
			new_chart_content_list.append(i)
	var history_chart: Array[ChartElement] = self.chart
	var loading_error: Error = self.load_chart("".join(new_chart_content_list))
	if self.load_chart("".join(new_chart_content_list)):
		print("Load Error: Chart.chart = ", self.chart)
		self.chart = history_chart
		return loading_error
	return OK


func export_chart() -> String:
	var result: String = ""
	for i in self.chart:
		if i is BPM:
			result += "(%s)" % i.bpm
		elif i is NoteTime:
			result += "{%s}" % i.note_time
		elif i is EmptyNote:
			result += ","
		elif i is TapNote:
			result += "%s," % i.track
		elif i is CatchNote:
			result += "%sc," % i.track
		elif i is HoldNote:
			result += "%sh[%s:%s]," % [i.track, i.hold_duration_note_time, i.hold_duration_note_count]
	return result


func _to_string() -> String:
	var result: String = "Chart(["
	for i in range(len(self.chart)):
		result += self.chart[i]._to_string() + ("" if i == len(self.chart) - 1 else ", ")
	return result + "])"


class ChartElement extends Chart:
	var note_duration: float
	var note_judgement_time: float
	var note_judgement_count: int
	
	func get_note_judgement_time(_index: int) -> float:
		var _note_judgement_time: float = 0
		if _index != 0:
			for i in chart.slice(0, _index):
				_note_judgement_time += i.note_duration
		return _note_judgement_time


class Note extends ChartElement:
	const PERFECT_RANGE: Array[float] = [-0.050, +0.050]
	const GREAT_EARLY_RANGE: Array[float] = [-0.100, -0.050]
	const GREAT_LATE_RANGE: Array[float] = [+0.050, +0.100]
	
	enum JudgementType { 
		PERFECT = 1,
		GREAT_EARLY = 2,
		GREAT_LATE = -2,
		MISS = 3,
	}
	
	func get_note_time(_index: int) -> int:
		var _note_time: int
		var chart_extracted: Array[ChartElement] = chart.slice(0, _index)
		chart_extracted.reverse()
		for i in chart_extracted:
			if i is NoteTime:
				_note_time = i.note_time
				break
		return _note_time
	
	func get_bpm(_index: int) -> float:
		var _bpm: float
		var chart_extracted: Array[ChartElement] = chart.slice(0, _index)
		chart_extracted.reverse()
		for i in chart_extracted:
			if i is BPM:
				_bpm = i.bpm
				break
		return _bpm
	
	func get_note_duration(_index: int) -> float:
		var note_time: int = self.get_note_time(_index)
		var bpm: float = self.get_bpm(_index)
		return (1.0 / bpm * 60.0) * (4.0 / note_time)
	
	func _get_judgement_result(_time: float, is_great_ignored: bool = false) -> Array:
		## 输出格式为: [time_deviation, judgement_type]
		var time_deviation: float = self.note_judgement_time - _time
		var judgement_type: JudgementType = JudgementType.MISS
		if self.PERFECT_RANGE[0] <= time_deviation and time_deviation < self.PERFECT_RANGE[1]:
			judgement_type = JudgementType.PERFECT
		elif self.GREAT_EARLY_RANGE[0] <= time_deviation and time_deviation < self.GREAT_EARLY_RANGE[1]:
			judgement_type = JudgementType.PERFECT if is_great_ignored else JudgementType.GREAT_EARLY
		elif self.GREAT_LATE_RANGE[0] <= time_deviation and time_deviation < self.GREAT_LATE_RANGE[1]:
			judgement_type = JudgementType.PERFECT if is_great_ignored else JudgementType.GREAT_LATE
		else:
			judgement_type = JudgementType.MISS
		return [time_deviation, judgement_type]
	
	func create_display() -> void:
		## 创建音符显示并匹配脚本
		pass		# 此处占位，由其子类覆写，如果不覆写那就是什么操作都不执行
	

class BPM extends ChartElement:
	var bpm: float
	func _init(_note_text: String, _index: int) -> void:
		## _note_text: (**<numbers>**)
		self.bpm = float(_note_text)
		self.note_duration = 0
		self.note_judgement_time = self.get_note_judgement_time(_index)
		self.note_judgement_count = 0

	func _to_string() -> String:
		return "BPM(%.2f)" % self.bpm


class NoteTime extends ChartElement:
	var note_time: int
	func _init(_note_text: String, _index: int) -> void:
		## _note_text: {**<numbers>**}
		self.note_time = int(_note_text)
		self.note_duration = 0
		self.note_judgement_time = self.get_note_judgement_time(_index)
		self.note_judgement_count = 0
	
	func _to_string() -> String:
		return "NoteTime(%s)" % self.note_time


class EmptyNote extends Note:
	func _init(_note_text: String, _index: int) -> void:
		## 这玩意儿虽然有输入字符串，但没啥用，因为它是占位符
		self.note_duration = self.get_note_duration(_index)
		self.note_judgement_time = self.get_note_judgement_time(_index)
		self.note_judgement_count = 0
	
	func _to_string() -> String:
		return "EmptyNote(%.3f)" % self.note_judgement_time
	

class TapNote extends Note:
	var track: int
	func _init(_note_text: String, _index: int) -> void:
		## _note_text: **[1-4]**
		self.track = int(_note_text)
		self.note_duration = self.get_note_duration(_index)
		self.note_judgement_time = self.get_note_judgement_time(_index)
		self.note_judgement_count = 1
		
	func _to_string() -> String:
		return "TapNote(%s, %.3f)" % [self.track, self.note_judgement_time]
	
	func get_judgement_result(_time: float) -> Array:
		## 输出格式为: [time_deviation, judgement_type]
		return self._get_judgement_result(_time)
	
	func create_display() -> void:
		## 创建音符显示并匹配脚本
		pass
	

class CatchNote extends Note:
	var track: int
	func _init(_note_text: String, _index: int) -> void:
		## _note_text: **[1-4]c**
		self.track = int(_note_text[0])
		self.note_duration = self.get_note_duration(_index)
		self.note_judgement_time = self.get_note_judgement_time(_index)
		self.note_judgement_count = 1
	
	func _to_string() -> String:
		return "CatchNote(%s, %.3f)" % [self.track, self.note_judgement_time]

	func get_judgement_result(_time: float) -> Array:
		## 输出格式为: [time_deviation, judgement_type]
		return self._get_judgement_result(_time, true)
		

class HoldNote extends Note:
	var track: int
	var hold_duration_note_time: int
	var hold_duration_note_count: int
	var hold_end_judgement_time: float
	var hold_duration: float
	func _init(_note_text: String, _index: int) -> void:
		## _note_text: **[1-4]h[[<numbers>:<numbers>]]**
		self.track = int(_note_text[0])
		self.note_duration = self.get_note_duration(_index)
		self.note_judgement_time = self.get_note_judgement_time(_index)
		self.note_judgement_count = 2
		self.hold_duration_note_time = int(_note_text.substr(
			_note_text.find('['), 
			_note_text.find(':') - _note_text.find('['),
		))
		self.hold_duration_note_count = int(_note_text.substr(
			_note_text.find(':'), 
			_note_text.find(']') - _note_text.find(':'),
		))
		var _bpm: float = self.get_bpm(_index)
		self.hold_duration = (1.0 / _bpm * 60.0) * (4.0 / self.hold_duration_note_time) * self.hold_duration_note_count
		self.hold_end_judgement_time = self.note_judgement_time + self.hold_duration
	
	func _to_string() -> String:
		return "HoldNote(%s, %.3f, %.3f)" % [self.track, self.hold_duration, self.note_judgement_time]
	
	func get_judgement_result(_time: float) -> Array:
		## 输出格式为: [time_deviation, judgement_type]
		return self._get_judgement_result(_time)

	func get_hold_end_judgement_result(_time: float) -> Array:
		## 输出格式为: [time_deviation, judgement_type]
		return self._get_judgement_result(_time, true)


class EachNote extends Note:
	var note_list: Array[Note]
	func _init(_note_text: String, _index: int) -> void:
		var match_pattern: RegEx = RegEx.new()
		var empty_note_match_result: Array[RegExMatch] = match_pattern.search_all(Chart.EMPTY_NOTE_MATCH_PATTERN)
		var tap_note_match_result: Array[RegExMatch] = match_pattern.search_all(Chart.TAP_NOTE_MATCH_PATTERN)
		var catch_note_match_result: Array[RegExMatch] = match_pattern.search_all(Chart.CATCH_NOTE_MATCH_PATTERN)
		var hold_note_match_result: Array[RegExMatch] = match_pattern.search_all(Chart.HOLD_NOTE_MATCH_PATTERN)
		var note_list_temp: Array[Array]
		for i in empty_note_match_result:
			note_list_temp.append(["EmptyNote", i.get_string()])
		for i in tap_note_match_result:
			note_list_temp.append(["TapNote", i.get_string()])
		for i in catch_note_match_result:
			note_list_temp.append(["CatchNote", i.get_string()])
		for i in hold_note_match_result:
			note_list_temp.append(["HoldNote", i.get_string()])
		for i in note_list_temp:
			if i[0] == "EmptyNote":
				pass   # note_list.append(EmptyNote.new(i[1], _index))
			elif i[0] == "TapNote":
				note_list.append(TapNote.new(i[1], _index))
			elif i[0] == "CatchNote":
				note_list.append(CatchNote.new(i[1], _index))
			elif i[0] == "HoldNote":
				note_list.append(HoldNote.new(i[1], _index))

	func _to_string() -> String:
		var result: String = "EachNote(["
		for i in range(len(self.note_list)):
			result += self.note_list[i]._to_string() + "" if i == len(self.note_list) - 1 else ", "
		return result + "], %s)" % self.note_judgement_time
	
	func get_judgement_result(_time: float, _idx: int, _hold_end: bool = false) -> Array:
		## 输出格式为: [time_deviation, judgement_type]
		## 如果索引到了EmptyNote，或_hold_end==true但是索引到的不是HoldNote，或下标越界，则返回空列表
		## _idx < 0时从列表尾索引
		var absolute_index: int = _idx if _idx >= 0 else len(self.note_list) + _idx
		if (
			(absolute_index < 0 or absolute_index >= len(self.note_list))
			or (self.note_list[absolute_index] is EmptyNote)
			or (_hold_end and self.note_list[absolute_index] is not HoldNote)
		):
			return []
		else:
			return (
				self.note_list[absolute_index].get_hold_end_judgement_result(_time) if _hold_end 
				else self.note_list[absolute_index].get_judgement_result(_time)
			)
