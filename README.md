# ShareByte

## О проекте: 
ShareByte - приложение для проведения презентаций между телефонами в условиях ограниченного интернета. 
Проект реализован в учебных целях в качестве выпускной работы курса [otus](https://otus.ru/lessons/advanced-ios/)

## Основные понятия: 
### Пользовательские роли
- Presenter - тот, кто проводит презентацию
- Viewew - тот, кто смотрит презентацию
### Состояние презентации
- Selecting - выбор контента для презентаций (на текущий момент только картинки) 
- Uploading - загрузка контента подключенным к сессии пользователям 
- Presentation - презентация контента подключенным к сессии пользователям 
### Вкладки 
- Presentation - проведение презентации 
- Peers - список найденных устройств для подключения к сессии и список подключенных к сессии пользователей 
- Me - тут пользователь выбирает аватар и задает свое имя
### Состояние поиска 
- Running - состояние поиска других пользователей и доступность видимости 
- Stopped - не ищем и не видны другим
## Основные библиотеки и фреймворки 
- [MultipeerConnectivity](https://developer.apple.com/documentation/multipeerconnectivity)
- [Realm](https://realm.io)  
## Пример взаимодействия 
- Два и более устройств открывают приложение
- Переход на вкладку Peers
<img width="1440" alt="image" src="https://github.com/MityuninDmitry/ShareByte/assets/11716199/f8c3b6a5-81a4-4a7f-88f3-5ea752ec724e">
- Один из пользователей нажимает на найденное устройство, в результате он становится Presenter, а другой Viewer
<img width="1397" alt="image" src="https://github.com/MityuninDmitry/ShareByte/assets/11716199/7a0e2ded-381a-4437-aa0d-a7c56efce0be">
- Presenter выбирает контент для шаринга
<img width="1388" alt="image" src="https://github.com/MityuninDmitry/ShareByte/assets/11716199/1506b1f1-6e99-45c8-905c-c30f6c114159">
- Нажимает upload to peers - в результате данные передаются на другие устройства сессии
<img width="1391" alt="image" src="https://github.com/MityuninDmitry/ShareByte/assets/11716199/4478b7da-234f-476f-8076-83bfbd554398">
- После загрузки Presenter нажимает на контент, чтобы тот открывался у Viewer
<img width="1407" alt="image" src="https://github.com/MityuninDmitry/ShareByte/assets/11716199/36f19599-a8d1-4ec1-aace-1a035b5b8c1b">
