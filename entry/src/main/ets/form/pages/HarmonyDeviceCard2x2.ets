let smartHomeCardStorage = new LocalStorage()

@Entry(smartHomeCardStorage)
@Component
struct HarmonyDeviceCard2x2 {
  @LocalStorageProp('title') title: string = 'Harmony 智能家居'
  @LocalStorageProp('subtitle') subtitle: string = '已连接 6 台设备'
  @LocalStorageProp('updatedAt') updatedAt: string = '最近更新 00:00'
  @LocalStorageProp('deviceId') deviceId: string = '1'
  @LocalStorageProp('deviceName') deviceName: string = '客厅主灯'
  @LocalStorageProp('deviceRoom') deviceRoom: string = '客厅'
  @LocalStorageProp('deviceParam') deviceParam: string = '亮度75%'
  @LocalStorageProp('deviceOnlineText') deviceOnlineText: string = '在线'
  @LocalStorageProp('deviceOnlineColor') deviceOnlineColor: string = '#4CAF50'
  @LocalStorageProp('deviceIcon') deviceIcon: string = 'icon_light.png'
  @LocalStorageProp('deviceButtonIcon') deviceButtonIcon: string = 'btn_power_on.png'
  @LocalStorageProp('deviceButtonBg') deviceButtonBg: string = '#1A1A1A'
  @LocalStorageProp('deviceButtonOpacity') deviceButtonOpacity: string = '1'

  build() {
    Stack() {
      Image($rawfile('bg.png'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      Column() {
        Row() {
          Column() {
            Text(this.title)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')
            Text(this.subtitle)
              .fontSize(11)
              .fontColor('#6B7280')
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Text(this.updatedAt)
            .fontSize(10)
            .fontColor('#8B8F97')
        }
        .width('100%')
        .margin({ bottom: 14 })

        Column() {
          Row() {
            Image($rawfile(this.deviceIcon))
              .width(52)
              .height(52)
              .margin({ right: 12 })

            Column() {
              Text(this.deviceName)
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1A1A1A')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

              Text(this.deviceRoom)
                .fontSize(12)
                .fontColor('#7B7F86')
                .margin({ top: 4 })

              Row() {
                Image($rawfile(this.deviceOnlineText === '在线' ? 'dot_online.png' : 'dot_offline.png'))
                  .width(8)
                  .height(8)
                  .margin({ right: 4 })
                Text(this.deviceOnlineText)
                  .fontSize(12)
                  .fontColor(this.deviceOnlineColor)
              }
              .margin({ top: 8 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .onClick(() => {
            postCardAction(this, {
              action: 'router',
              abilityName: 'EntryAbility',
              params: {
                targetDeviceId: this.deviceId
              }
            })
          })

          Text(this.deviceParam)
            .width('100%')
            .fontSize(13)
            .fontColor('#6B7280')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ top: 18, bottom: 18 })

          Button() {
            Image($rawfile(this.deviceButtonIcon))
              .width(22)
              .height(22)
          }
          .width(54)
          .height(54)
          .borderRadius(27)
          .opacity(Number(this.deviceButtonOpacity))
          .backgroundColor(this.deviceButtonBg)
          .alignSelf(ItemAlign.End)
          .onClick(() => {
            if (this.deviceOnlineText === '在线') {
              postCardAction(this, {
                action: 'message',
                params: {
                  operation: 'toggle',
                  deviceId: this.deviceId
                }
              })
            }
          })
        }
        .width('100%')
        .padding(18)
        .borderRadius(24)
        .border({ width: 1, color: '#66FFFFFF' })
        .backgroundColor('#B8FFFFFF')
        .shadow({ radius: 20, color: '#26000000', offsetX: 0, offsetY: 8 })
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .backgroundColor('#1A101826')
    }
    .width('100%')
    .height('100%')
  }
}
