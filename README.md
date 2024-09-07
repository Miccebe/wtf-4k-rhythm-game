## 写在前面

这个4k音游纯粹是写着玩的，***!!!不是正式的音游企划!!!***

作者是笨比，不太会操作Github仓库，代码都在recover分支里，但是我不知道该怎么合并到origin/main分支里去

---

## 谱面格式

`(<BPM>)`: 标记段落BPM为`<BPM>`，例如`(188)`, `(-147.75)`

`{<NoteTime>}`: 标记段落分音为`<NoteTime>`分音，例如`{4}`, `{24}`, `{14}`

`,`: 标记空音符

`<Track>,`: 标记在`<Track>`轨上的Tap音符，例如`1,`

`<Track>c,`: 标记在`<Track>`轨上的Catch音符，例如`2c,`

`<Track>h[<NoteTime>:<Count>]`: 标记在`<Track>`轨上的持续`<Count>`个`<NoteTime>`分音的Hold音符，例如`3h[8:3],`, `4h[1:0]`

用`/`连接多个音符（去掉结尾的`,`）来标记多押，并在结尾补上`,`

不支持注释

谱面文件开头可加入如下内容，标记乐曲基本信息（注：键、值两边的空格会被自动忽略）：

`$song_name=<SongName>`: 标记乐曲名称为`<SongName>`

`$composer=<Composer>`: 标记乐曲的曲师为`<Composer>`

`$chart_designer=<ChartDesigner>`: 标记谱面的谱师为`<ChartDesigner>`

`$illustrator=<Illustrator>`: 标记曲绘的画师为`<Illustrator>`

`$bpm=<BPM>`: 标记谱面的基准BPM为`<BPM>`

注：如果没有在谱面文件开头声明BPM，那么读取谱面时会自动把谱面开头的第一个BPM标记作为基准BPM



