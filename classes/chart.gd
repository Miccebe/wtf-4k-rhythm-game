class_name Chart

var chart: Array[ChartElement] = []
#var bpm_list: Array[int] = []

enum Track {
	TRACK_1 = 1,
	TRACK_2 = 2,
	TRACK_3 = 3,
	TRACK_4 = 4,
}

const BPM_MATCH_PATTERN: String = r"(?<=\()\-?\d+\.?(\d+)?(?=\))"
const NOTE_TIME_MATCH_PATTERN: String = r"(?<=\{)\d+(?=\})"
const SINGLE_EMPTY_NOTE_MATCH_PATTERN: String = r"(?<=[)},])(?=,)"
const SINGLE_TAP_NOTE_MATCH_PATTERN: String = r"(?<=[)},])[1-4](?=,)"
const SINGLE_CATCH_NOTE_MATCH_PATTERN: String = r"(?<=[)},])[1-4]c(?=,)"
const SINGLE_HOLD_NOTE_MATCH_PATTERN: String = r"(?<=[)},])[1-4]h\[\d+:\d+](?=,)"
const EACH_NOTE_MATCH_PATTERN: String = r"(?<=[)},])([0-9ch\[:\]]*/)+[0-9ch\[:\]]*(?=,)"
const ANY_SINGLE_NOTE_MATCH_PATTERN: String = r"[1-4](c|h\[\d+:\d+])?"


func load_chart(_chart_content_text: String) -> Error:
	var chart_content_text: String = _chart_content_text.strip_escapes().replace(' ',"")
	#LogScript.write_log(["Loading Chart: chart_content_text = " + chart_content_text])
	# 读取各个note匹配信息
	var match_pattern: RegEx = RegEx.new()
	match_pattern.compile(Chart.BPM_MATCH_PATTERN)
	var bpm_match_result: Array[RegExMatch] = match_pattern.search_all(chart_content_text)
	if bpm_match_result.is_empty():
		LogScript.write_log(["Load Error: Empty BPM List"])
		return ERR_INVALID_PARAMETER
	match_pattern.compile(Chart.NOTE_TIME_MATCH_PATTERN)
	var note_time_match_result: Array[RegExMatch] = match_pattern.search_all(chart_content_text)
	if note_time_match_result.is_empty():
		LogScript.write_log(["Load Error: Empty Note Time List"])
		return ERR_INVALID_PARAMETER
	match_pattern.compile(Chart.SINGLE_EMPTY_NOTE_MATCH_PATTERN)
	var empty_note_match_result: Array[RegExMatch] = match_pattern.search_all(chart_content_text)
	match_pattern.compile(Chart.SINGLE_TAP_NOTE_MATCH_PATTERN)
	var tap_note_match_result: Array[RegExMatch] = match_pattern.search_all(chart_content_text)
	match_pattern.compile(Chart.SINGLE_CATCH_NOTE_MATCH_PATTERN)
	var catch_note_match_result: Array[RegExMatch] = match_pattern.search_all(chart_content_text)
	match_pattern.compile(Chart.SINGLE_HOLD_NOTE_MATCH_PATTERN)
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
	#LogScript.write_log(["Loading Chart: chart_content_list = ", chart_content_list])
	# 把标记了字符串信息的列表转成ChartElement列表
	self.chart = []
	var each_note_temp: EachNote
	var each_note_content_count: int = 0
	for i in range(len(chart_content_list)):
		if chart_content_list[i][0] == "BPM":
			self.chart.append(BPM.new(chart_content_list[i][1], i, self.chart))
		elif chart_content_list[i][0] == "NoteTime":
			self.chart.append(NoteTime.new(chart_content_list[i][1], i, self.chart))
		elif chart_content_list[i][0] == "EmptyNote":
			self.chart.append(EmptyNote.new(chart_content_list[i][1], i, self.chart))
		elif chart_content_list[i][0] == "TapNote":
			self.chart.append(TapNote.new(chart_content_list[i][1], i, self.chart))
		elif chart_content_list[i][0] == "CatchNote":
			self.chart.append(CatchNote.new(chart_content_list[i][1], i, self.chart))
		elif chart_content_list[i][0] == "HoldNote":
			self.chart.append(HoldNote.new(chart_content_list[i][1], i, self.chart))
		elif chart_content_list[i][0] == "EachNote":
			each_note_temp = EachNote.new(chart_content_list[i][1], i, self.chart)
			each_note_content_count += len(each_note_temp.note_list)
			if each_note_temp.note_list != []:
				self.chart.append(each_note_temp)
	if len(tap_note_match_result) + len(catch_note_match_result) + len(hold_note_match_result) + each_note_content_count < 1:
		LogScript.write_log(["Load Error: Empty Note List"])
		self.chart = []
		return ERR_INVALID_PARAMETER
	LogScript.write_log(["Chart load complete: self.chart = ", self.chart, "\nOutput chart:\n", self.export_chart()])
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
		LogScript.write_log(["Load Error: Chart.chart = ", self.chart])
		self.chart = history_chart
		return loading_error
	return OK


func export_chart(formatted: bool = false, line_sep_note_time: String = "[1:4]") -> String:
	## 如果谱面读取失败，则返回空字符串
	## 如果new_line参数格式错误或计算得出的时间为0，那么就按照默认值"[1:4]"处理，并在日志中添加一行Warning
	var get_note_time = func(_note_time_text: String) -> float:
		# note_time计算出来的结果是把音符时值拉伸到以1个四分音符为基准（1个四分音符的时值为1），例如"[8:3]"的计算结果是0.75
		var note_time_list: PackedStringArray = _note_time_text.split(":")
		return 4 / float(note_time_list[0][1]) * float(note_time_list[1][0])

	var check_match: RegEx = RegEx.new()
	check_match.compile(r"\[\d+:\d+]")
	if check_match.search(line_sep_note_time).get_string() != line_sep_note_time:
		LogScript.write_log(["Warning: Invalid line_sep_note_time parameter. Using default value: \"[1:4]\""])
		line_sep_note_time = "[1:4]"
	elif get_note_time.call(line_sep_note_time) <= 0:
		LogScript.write_log(["Warning: Parameter line_sep_note_time should be greater than 0. Using default value: \"[1:4]\""])
		line_sep_note_time = "[1:4]"
	var result: String = ""
	var note_time_sum: float = 0
	var note_time_max: float = get_note_time.call(line_sep_note_time)
	var current_note_time: int
	for i in self.chart:
		if i is BPM:
			result += "(%s)" % i.bpm
		elif i is NoteTime:
			result += "{%s}" % i.note_time
			current_note_time = i.note_time
		elif i is EmptyNote:
			result += ","
			note_time_sum += get_note_time.call("[%s:1]" % current_note_time)
		elif i is TapNote:
			result += "%s," % i.track
			note_time_sum += get_note_time.call("[%s:1]" % current_note_time)
		elif i is CatchNote:
			result += "%sc," % i.track
			note_time_sum += get_note_time.call("[%s:1]" % current_note_time)
		elif i is HoldNote:
			result += "%sh[%s:%s]," % [
				i.track, 
				i.hold_duration_note_time, 
				i.hold_duration_note_count
			]
			note_time_sum += get_note_time.call("[%s:1]" % current_note_time)
		elif i is EachNote:
			for j in range(len(i.note_list)):
				if i.note_list[j] is EmptyNote:
					result += "," if j == len(i.note_list) - 1 else "/"
				elif i.note_list[j] is TapNote:
					result += "%s" % i.note_list[j].track + ("," if j == len(i.note_list) - 1 else "/")
				elif i.note_list[j] is CatchNote:
					result += "%sc" % i.note_list[j].track + ("," if j == len(i.note_list) - 1 else "/")
				elif i.note_list[j] is HoldNote:
					result += (
						"%sh[%s:%s]" % [
							i.note_list[j].track, 
							i.note_list[j].hold_duration_note_time, 
							i.note_list[j].hold_duration_note_count
						] 
						+ ("," if j == len(i.note_list) - 1 else "/")
					)
			note_time_sum += get_note_time.call("[%s:1]" % current_note_time)
		if formatted and note_time_sum >= note_time_max:
			result += "\n"
			note_time_sum = 0
	return result


func _to_string() -> String:
	var result: String = "Chart(["
	for i in range(len(self.chart)):
		result += self.chart[i]._to_string() + ("" if i == len(self.chart) - 1 else ", ")
	return result + "])"


func get_track(_text) -> Track:
	var _value: int = int(_text)
	if _value == 1:
		return Track.TRACK_1
	elif _value == 2:
		return Track.TRACK_2
	elif _value == 3:
		return Track.TRACK_3
	else:  # _value == 4
		return Track.TRACK_4


class ChartElement extends Chart:
	var note_duration: float
	var note_judgement_time: float
	var note_judgement_count: int
	
	func get_note_judgement_time(_index: int) -> float:
		var _note_judgement_time: float = 0.0
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
		var chart_extracted: Array[ChartElement] = self.chart.slice(0, _index)
		chart_extracted.reverse()
		for i in chart_extracted:
			if i is NoteTime:
				_note_time = i.note_time
				break
		return _note_time
	
	func get_bpm(_index: int) -> float:
		var _bpm: float
		var chart_extracted: Array[ChartElement] = self.chart.slice(0, _index)
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


class BPM extends ChartElement:
	var bpm: float
	func _init(_note_text: String, _index: int, _before_chart: Array[ChartElement]) -> void:
		## _note_text: (**<numbers>**)
		self.chart = _before_chart
		self.bpm = int(float(_note_text) * 100) / 100.0
		self.note_duration = 0
		self.note_judgement_time = self.get_note_judgement_time(_index)
		self.note_judgement_count = 0
		#LogScript.write_log(["BPM Added: \"", _note_text, "\" to ", self._to_string()])

	func _to_string() -> String:
		return "BPM(%.2f, %.3f)" % [self.bpm, self.note_judgement_time]


class NoteTime extends ChartElement:
	var note_time: int
	func _init(_note_text: String, _index: int, _before_chart: Array[ChartElement]) -> void:
		## _note_text: {**<numbers>**}
		self.chart = _before_chart
		self.note_time = int(_note_text)
		self.note_duration = 0
		self.note_judgement_time = self.get_note_judgement_time(_index)
		self.note_judgement_count = 0
		#LogScript.write_log(["NoteTime Added: \"", _note_text, "\" to ", self._to_string()])
	
	func _to_string() -> String:
		return "NoteTime(%s, %.3f)" % [self.note_time, self.note_judgement_time]


class EmptyNote extends Note:
	func _init(_note_text: String, _index: int, _before_chart: Array[ChartElement]) -> void:
		## 这玩意儿虽然有输入字符串，但没啥用，因为它是占位符
		self.chart = _before_chart
		self.note_duration = self.get_note_duration(_index)
		self.note_judgement_time = self.get_note_judgement_time(_index)
		self.note_judgement_count = 0
		#LogScript.write_log(["EmptyNote Added: \"", _note_text, "\" to ", self._to_string(), ", self.note_duration = ", self.note_duration])
	
	func _to_string() -> String:
		return "EmptyNote(%.3f)" % self.note_judgement_time
	

class TapNote extends Note:
	var track: Track = Track.TRACK_1
	func _init(_note_text: String, _index: int, _before_chart: Array[ChartElement]) -> void:
		## _note_text: **[1-4]**
		self.chart = _before_chart
		self.track = self.get_track(_note_text)
		self.note_duration = self.get_note_duration(_index)
		self.note_judgement_time = self.get_note_judgement_time(_index)
		self.note_judgement_count = 1
		#LogScript.write_log(["TapNote Added: \"", _note_text, "\" to ", self._to_string(), ", self.note_duration = ", self.note_duration])
		
	func _to_string() -> String:
		return "TapNote(%s, %.3f)" % [self.track, self.note_judgement_time]
	
	func get_judgement_result(_time: float) -> Array:
		## 输出格式为: [time_deviation, judgement_type]
		return self._get_judgement_result(_time)


class CatchNote extends Note:
	var track: Track = Track.TRACK_1
	func _init(_note_text: String, _index: int, _before_chart: Array[ChartElement]) -> void:
		## _note_text: **[1-4]c**
		self.chart = _before_chart
		self.track = self.get_track(_note_text[0])
		self.note_duration = self.get_note_duration(_index)
		self.note_judgement_time = self.get_note_judgement_time(_index)
		self.note_judgement_count = 1
		#LogScript.write_log(["CatchNote Added: \"", _note_text, "\" to ", self._to_string(), ", self.note_duration = ", self.note_duration])
	
	func _to_string() -> String:
		return "CatchNote(%s, %.3f)" % [self.track, self.note_judgement_time]

	func get_judgement_result(_time: float) -> Array:
		## 输出格式为: [time_deviation, judgement_type]
		return self._get_judgement_result(_time, true)
		

class HoldNote extends Note:
	var track: Track = Track.TRACK_1
	var hold_duration_note_time: int
	var hold_duration_note_count: int
	var hold_end_judgement_time: float
	var hold_duration: float
	func _init(_note_text: String, _index: int, _before_chart: Array[ChartElement]) -> void:
		## _note_text: **[1-4]h[[<numbers>:<numbers>]]**
		self.chart = _before_chart
		self.track = self.get_track(_note_text[0])
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
		#LogScript.write_log(["HoldNote Added: \"", _note_text, "\" to ", self._to_string(), ", self.note_duration = ", self.note_duration])
	
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
	func _init(_note_text: String, _index: int, _before_chart: Array[ChartElement]) -> void:
		self.chart = _before_chart
		self.note_duration = self.get_note_duration(_index)
		self.note_judgement_time = self.get_note_judgement_time(_index)
		self.note_judgement_count = 0
		var note_text_list: PackedStringArray = _note_text.split('/', false)
		var match_pattern: RegEx = RegEx.new()
		match_pattern.compile(Chart.ANY_SINGLE_NOTE_MATCH_PATTERN)
		for i in note_text_list:
			var note_matched: RegExMatch = match_pattern.search(i)
			if note_matched and note_matched.get_string() == i:
				if i.find('c') != -1:
					self.note_list.append(CatchNote.new(i, _index, self.chart))
					self.note_judgement_count += 1
				elif i.find('h') != -1:
					self.note_list.append(HoldNote.new(i, _index, self.chart))
					self.note_judgement_count += 2
				else:
					self.note_list.append(TapNote.new(i, _index, self.chart))
					self.note_judgement_count += 1
				#print("note_matched.get_string() = ", note_matched.get_string(), ", self.note_list[-1] = ", self.note_list[-1])
		#LogScript.write_log(["EachNote Added: \"", _note_text, "\" to ", self._to_string(), ", self.note_duration = ", self.note_duration])

	func _to_string() -> String:
		var result: String = "EachNote(["
		for i in range(len(self.note_list)):
			result += self.note_list[i]._to_string() + ("" if i == len(self.note_list) - 1 else ", ")
		return result + "], %.3f)" % self.note_judgement_time
	
	func get_judgement_result(_time: float, _idx: int, _hold_end: bool = false) -> Array:
		## 输出格式为: [time_deviation, judgement_type]
		## 如果_hold_end==true但是索引到的不是HoldNote，或下标越界，则返回空列表
		## _idx < 0时从列表尾索引
		var absolute_index: int = _idx if _idx >= 0 else len(self.note_list) + _idx
		if (
			(absolute_index < 0 or absolute_index >= len(self.note_list))
			or (_hold_end and self.note_list[absolute_index] is not HoldNote)
		):
			return []
		else:
			return (
				self.note_list[absolute_index].get_hold_end_judgement_result(_time) if _hold_end 
				else self.note_list[absolute_index].get_judgement_result(_time)
			)
