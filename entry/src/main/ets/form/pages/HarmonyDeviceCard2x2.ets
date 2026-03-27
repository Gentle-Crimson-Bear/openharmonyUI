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
          Text('智能家居')
            .layoutWeight(1)
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Row() {
            Image($rawfile(this.deviceOnlineText === '在线' ? 'dot_online.png' : 'dot_offline.png'))
              .width(8)
              .height(8)
          }
          .width(18)
          .height(18)
          .justifyContent(FlexAlign.Center)
          .borderRadius(9)
          .backgroundColor('#26FFFFFF')
        }
        .width('100%')

        Column({ space: 10 }) {
          Image($rawfile(this.deviceIcon))
            .width(48)
            .height(48)
            .objectFit(ImageFit.Contain)

          Text(this.deviceName)
            .width('100%')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')
            .textAlign(TextAlign.Center)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Button() {
            Image($rawfile(this.deviceButtonIcon))
              .width(18)
              .height(18)
          }
          .width(42)
          .height(42)
          .borderRadius(21)
          .opacity(Number(this.deviceButtonOpacity))
          .backgroundColor(this.deviceButtonBg)
          .onClick(() => {
            this.postToggleAction()
          })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.routeToDevice()
        })
      }
      .width('100%')
      .height('100%')
      .padding({ left: 12, right: 12, top: 12, bottom: 12 })
      .borderRadius(24)
      .border({ width: 1, color: '#66FFFFFF' })
      .backgroundColor('#B8FFFFFF')
      .shadow({ radius: 20, color: '#26000000', offsetX: 0, offsetY: 8 })
    }
    .width('100%')
    .height('100%')
    .padding(8)
    .backgroundColor('#16101826')
  }

  routeToDevice(): void {
    postCardAction(this, {
      action: 'router',
      abilityName: 'EntryAbility',
      params: {
        targetDeviceId: this.deviceId
      }
    })
  }

  postToggleAction(): void {
    if (this.deviceOnlineText !== '在线') {
      return
    }
    postCardAction(this, {
      action: 'message',
      params: {
        operation: 'toggle',
        deviceId: this.deviceId
      }
    })
  }
}
