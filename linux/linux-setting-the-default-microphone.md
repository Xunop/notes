# Linux 设置默认麦克风

最近在想办法医治我的拖延症，于是从各种出现的小问题开始解决。因为我其中一台笔记本在飞书开会的时候经常会出现默认麦克风无法使用的情况，经常需要调整，不说很大的问题，但是也是一个小问题。

没有使用 PulseAudio 作为我的音频服务器，如果是想查看 PulseAudio 的设置方法，参考 [Arch Wiki](https://wiki.archlinux.org/title/PulseAudio/Examples#Set_default_input_source)。

通过 PipeWire 设置默认麦克风。最开始我参考 [Arch Wiki](https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture/Troubleshooting#Setting_the_default_microphone/capture_device)
中的内容，使用 `arecord -L` 查看所有设备：

```bash
arecord -L
```

输出：

```
null
    Discard all samples (playback) or generate zero samples (capture)
pipewire
    PipeWire Sound Server
default
    Default ALSA Output (currently PipeWire Media Server)
sysdefault:CARD=sofhdadsp
    sof-hda-dsp,
    Default Audio Device
```

才发现默认麦克风由 PipeWire 控制。所以直接配置 PipeWire 来选择默认的录音设备，不修改 `~/.asoundrc`。

查看麦克风设备：

```bash
pactl list short sources
```

输出：

```
48      alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI3__sink.monitor       PipeWire s24-32le 2ch 48000Hz    SUSPENDED
49      alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI2__sink.monitor       PipeWire s24-32le 2ch 48000Hz    SUSPENDED
50      alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI1__sink.monitor       PipeWire s24-32le 2ch 48000Hz    SUSPENDED
51      alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink.monitor     PipeWire s32le 2ch 48000Hz       SUSPENDED
52      alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic2__source       PipeWires24-32le 2ch 48000Hz     SUSPENDED
53      alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source       PipeWires32le 2ch 48000Hz        SUSPENDED
```

所以到底哪一个是有效的麦克风呢？我并没有去往下查找这些麦克风命名的规范以及各种信息，可以看到最右边的输出是 SUSPENDED，所以可以通过开启麦克风来进行测试（我也不知道为什么使用 arecord 命令麦克风会正常工作，或许是全遍历一边吧）：

```bash
arecord -vv --format=dat /dev/null
```

这时，就可以发现处于 RUNNING 的麦克风设备是可以正常工作的了，选择设备名称，设置为默认麦克风：

```bash
pactl set-default-source <source-name>
```

验证一下：

```bash
pactl info | grep "Default Source"
```

好，现在飞书会议麦克风设置成系统默认也可以正常工作了。

参考：

- https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture/Troubleshooting#Setting_the_default_microphone/capture_device
- https://wiki.archlinux.org/title/PulseAudio/Examples#Set_default_input_source
