//
//  SentencesModel.swift
//  SwiftUIDemo
//
//  Created by 墨枫 on 2024/1/7.
//

import SwiftUI

struct SentencesModel: Identifiable {
    var id: UUID = UUID()
    var image: String
    var text: String
}

var Sentences: [SentencesModel] = [
    SentencesModel(image: "icon_weixin", text: "微信账号"),
    SentencesModel(image: "icon_qq", text: "QQ账号"),
    SentencesModel(image: "icon_weibo", text: "新浪微博"),
    SentencesModel(image: "icon_xiaohongshu", text: "小红书"),
    SentencesModel(image: "icon_douyin", text: "抖音账号"),
    SentencesModel(image: "icon_bilibili", text: "哔哩哔哩"),
    SentencesModel(image: "icon_zhihu", text: "知乎账号"),
]
