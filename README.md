# lx-music-lyrics
Display LX Music lyrics on the KDE plasma panel.      

在 KDE plasma 面板上显示 LX Music 的歌词。 

## 效果
![image text](https://github.com/kzlouge/org.kde.plasma.lx-music-lyrics/blob/main/lx-music-lyrics-example.png)  



## 前言    

YesPlayMusic 在 KDE plasma 上有[插件](https://github.com/zsiothsu/org.kde.plasma.yesplaymusic-lyrics)可以在面板上显示歌词，这样听歌的时候歌词不会遮挡代码，代码也不会遮挡歌词，体验非常不错。这个插件是通过调用 YesPlayMusic 提供的 API 获取歌词的。

后来使用 LX Music 的时候，发现 LX Music 没有类似的插件，也没有开放类似的接口。

LX Music 从 v2.7.0 起支持开放 [API服务](https://lxmusic.toside.cn/desktop/open-api)，启用开放API功能后，将会在本地启动一个http服务，提供接口供第三方软件调用。

因此便打算为 LX Muic 也写一个在 KDE plasma 面板中显示歌词的插件。 

该插件全部由 qml 前端编写，调用 API 获取歌词后把歌词显示在面板上，用户可以自行设置歌词的字体、颜色和是否显示翻译和罗马音。

## 原理

LX Music 开启[API服务](https://lxmusic.toside.cn/desktop/open-api)后，提供三个接口获取歌曲信息：

1. `http://127.0.0.1:23330/status` 用于获取播放器状态

2. `http://127.0.0.1:23330/lyric` 用于获取歌词

3. `http://127.0.0.1:23330/subscribe-player-status` SSE事件流接口, 接受一个普通的 HTTP GET 请求，只是请求会保持长链接状态，播放器的状态在变更时通过文本事件流的形式将其实时返回

这里选择使用SSE接口获取歌词，避免通过轮询的方式重复调用状态接口查询歌词。但为了检测软件运行和连接中断后重连，仍然是重复调用SSE接口，或许有更好的解决方法。


KDE Plasma 的插件使用 QML 开发前端（[相关教程](https://develop.kde.org/docs/plasma/widget/)），QML 集成了 JavaScript，在 JavaScript 中 SSE 连接是通过 EventSource 进行的。但 QML 并没有实现 EventSource, 好在 QML 实现了 XMLHttpRequest，而 SSE 基于 HTTP 协议，可以由 XMLHttpRequest 实现。

插件通过接口实时更新数据后，从数据中提取歌词并更新在面板上，在连接断开后每5秒尝试重新连接。

## 安装

1. 通过 GITHUB：  
```shell
git clone https://github.com/kzlouge/org.kde.plasma.lx-music-lyrics
mv org.kde.plasma.lx-music-lyrics ~/.local/share/plasma/plasmoids/org.kde.plasma.lx-music-lyrics
```

2. 在 KDE Store 中下载： https://store.kde.org/p/2166807

3. 
  1. 右键待安装插件的面板，点击`添加挂件`，点击`获取新挂件`，点击`下载 Plasma 挂件`

  2. 在弹出的界面中，搜索`lx-music-lyrics`，并点击安装

## 运行

1. 在 LX Music `设置-开放API` 中勾选 `启用开放API服务` 选项，并确认服务端口为 `23330` 

2. 如需显示歌词翻译和罗马音，请在 LX Music `设置`-`播放设置` 中勾选`显示歌词翻译（如果可用）`和`显示歌词罗马音（如果可用）`





