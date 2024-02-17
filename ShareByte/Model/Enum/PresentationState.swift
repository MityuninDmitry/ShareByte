//
//  PresentationStates.swift
//  ShareByte
//
//  Created by Dmitry Mityunin on 7/16/23.
//

import Foundation

enum PresentationState: String, Codable {
    case selecting = "SELECTING" // выбор картинок, стартовое состояние = 0 выбранных картинок И 0 в презентации
    case preparing = "PREPARING" // подготовка картинок к загрузке. выбранных картинок != 0 и катинок в презентации !=0
    case prepared = "PREPARED" // подготовлены к загрузке. Приходим в это состояние, когда количество выбранных = количеству в презентации и они не равны 0
    case uploading = "UPLOADING" // отправка пользователям. 
    case presentation = "PRESENTATION" // презентация
}
