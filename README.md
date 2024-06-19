# lx-music-lyrics
Display LX Music lyrics on the KDE plasma panel.      

在 KDE plasma 面板上显示 LX Music 的歌词。 

## 效果
![image text](https://github.com/kzlouge/org.kde.plasma.lx-music-lyrics/blob/main/lx-music-lyrics-example.png)  



## 前言

YesPlayMusic 在 KDE plasma 上有[插件](https://github.com/zsiothsu/org.kde.plasma.yesplaymusic-lyrics)可以在面板上显示歌词，听歌的时候歌词不会有遮挡，非常不错。这是通过 YesPlayMusic 的接口获取歌词的。

但 LX Music 没有相关的插件，之前也没有开放类似的接口。
LX Music 从 v2.7.0 起支持开放 [API服务](https://lxmusic.toside.cn/desktop/open-api)，启用开放API功能后，将会在本地启动一个http服务，提供接口供第三方软件调用。

因此便有了为 LX Muic 也写一个在 KDE plasma 面板中显示歌词的插件的想法。

该插件全部由 qml 前端编写，代码量不到 100 行，只能实现最基本的把歌词显示在面板上的功能，后续会添加一些自定义设置。

## 原理

LX Music 开启[API服务](https://lxmusic.toside.cn/desktop/open-api)后，提供三个接口获取歌曲信息：

1. `http://127.0.0.1:23330/status` 用于获取播放器状态

2. `http://127.0.0.1:23330/lyric` 用于获取歌词

3. `http://127.0.0.1:23330/subscribe-player-status` SSE事件流接口, 接受一个普通的 HTTP GET 请求，只是请求会保持长链接状态，播放器的状态在变更时通过文本事件流的形式将其实时返回

这里选择使用SSE接口获取歌词，避免通过轮询的方式重复调用状态接口。

QML 前端集成了 JavaScript，在 JavaScript 中 SSE 连接是通过 EventSource 进行的。但 QML 并没有实现 EventSource, 好在 QML 实现了 XMLHttpRequest，而 SSE 基于 HTTP 协议，可以由 XMLHttpRequest 实现。

插件通过接口实时更新数据后，从数据中提取歌词并更新在面板上，在连接断开后每5秒尝试重新连接。

## 安装

下载得到代码后，复制到 KDE Plasma 用于存放插件的文件夹中：

```shell
git clone https://github.com/kzlouge/org.kde.plasma.lx-music-lyrics
cp -r org.kde.plasma.lx-music-lyrics ~/.local/share/plasma/plasmoids/org.kde.plasma.lx-music-lyrics
```
或者在 KDE Store 中下载：
`https://store.kde.org/p/2166807`
