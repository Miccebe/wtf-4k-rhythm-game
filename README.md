## 写在前面

这个4k音游纯粹是写着玩的，***!!!不是正式的音游企划!!!***

作者是笨比，不会操作Github仓库，代码都在recover分支里，但是我不知道该怎么合并到origin/main分支里去

---

## 谱面文件夹格式

曲绘文件名为`bg.png`，图片尺寸不限，图片最终会被拉伸成正方形

音乐文件名为`track.mp3`

谱面文件名为`chart.txt`，谱面格式[见下文](#谱面格式)

<!--注：如果要往一个谱面文件夹里存放多个谱面，请添加一个`chart_list.json`文件，格式[见下文](#chart_listjson文件格式)，并根据`chart_list.json`文件内定义的引用文件，在文件夹内放入对应的谱面文件。如果定义了`chart_list.json`文件，则游戏会优先读取`chart_list.json`文件，而不是`chart.txt`-->

---

## 谱面格式

> 整体与Simai语法十分类似，因为作者是wmc（绝对不是因为不熟悉马老弟的谱面格式）

`(<BPM>)`: 标记段落BPM为`<BPM>`，例如`(188)`, `(-147.75)`

`{<NoteTime>}`: 标记段落分音为`<NoteTime>`分音，例如`{4}`, `{24}`, `{14}`

`,`: 标记空音符

`<Track>,`: 标记在`<Track>`轨上的Tap音符，例如`1,`

`<Track>c,`: 标记在`<Track>`轨上的Catch音符，例如`2c,`

`<Track>h[<NoteTime>:<Count>]`: 标记在`<Track>`轨上的持续`<Count>`个`<NoteTime>`分音的Hold音符，例如`3h[8:3],`, `4h[1:0]`；Hold音符的长度计算基于Hold起始BPM，也就是说如果Hold音符跨越BPM，Hold音符的长度计算还是基于Hold音符开始时间点的BPM

用`/`连接多个音符（去掉结尾的`,`）来标记多押，并在结尾补上`,`

不支持注释

谱面文件开头可加入如下内容，标记乐曲基本信息（键、值两边的空格会被自动忽略）：

`$song_name=<SongName>`: 标记乐曲名称为`<SongName>`，缺省值为`Unnamed Song`

`$composer=<Composer>`: 标记乐曲的曲师为`<Composer>`，缺省值为`Unknown Composer`

`$chart_designer=<ChartDesigner>`: 标记谱面的谱师为`<ChartDesigner>`，缺省值为空字符串

`$illustrator=<Illustrator>`: 标记曲绘的画师为`<Illustrator>`，缺省值为空字符串

`$preview_clip=<PreviewClip>`: 标记预览片段为`<PreviewClip>`；值的格式为`<StartTime>-<EndTime>`，例如`0:19-0:40`；缺省值为`0:00-0:30`；音频预览结束前会进行3秒的音频淡化，并且这3秒是包含在预览片段定义的时间里的

`$bpm=<BaseBPM>`: 标记谱面的基准BPM为`<BaseBPM>`，若未指定，则会把谱面开头的第一个BPM标记作为基准BPM

`$offset=<Offset>`: 标记谱面的音频延迟为`<Offset>`毫秒，缺省值为`0`

<!-----

## chart_list.json文件格式

文件使用标准JSON文件格式，以下是一个示例

``` JSON
{
    "chart_list": [
        {
            "name": "Normal",
            "level": 11,
            "file": "chart.txt"
        },
        {
            "name": "Hard",
            "level": 15,
            "file": "chart2.txt"
        },
        {
            "name": "Insane",
            "level": 21,
            "file": "chart3.txt"
        }
    ]
}
```

+ Compound: 根标签
    + List - `chart_list`: 存放谱面文件引用列表
        + Compound: 一个谱面文件引用
            + String - `name`: 谱面的名称
            + Number - `level`: 谱面的难度标级
            + String - `file`: 谱面文件的名称（包含文件后缀）

注：如果引用的文件不存在，则游戏读取时会忽略该项-->

