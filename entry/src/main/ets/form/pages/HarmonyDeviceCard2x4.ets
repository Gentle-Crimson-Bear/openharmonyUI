let smartHomeWideCardStorage = new LocalStorage()

@Entry(smartHomeWideCardStorage)
@Component
struct HarmonyDeviceCard2x4 {
  @LocalStorageProp('title') title: string = 'Harmony 智能家居'
  @LocalStorageProp('subtitle') subtitle: string = '桌面联动中 · 6 台设备'
  @LocalStorageProp('updatedAt') updatedAt: string = '最近更新 00:00'
  @LocalStorageProp('primaryId') primaryId: string = '1'
  @LocalStorageProp('primaryName') primaryName: string = '客厅主灯'
  @LocalStorageProp('primaryRoom') primaryRoom: string = '客厅'
  @LocalStorageProp('primaryParam') primaryParam: string = '亮度75%'
  @LocalStorageProp('primaryOnlineText') primaryOnlineText: string = '在线'
  @LocalStorageProp('primaryOnlineColor') primaryOnlineColor: string = '#4CAF50'
  @LocalStorageProp('primaryIcon') primaryIcon: string = 'icon_light.png'
  @LocalStorageProp('primaryButtonIcon') primaryButtonIcon: string = 'btn_power_on.png'
  @LocalStorageProp('primaryButtonBg') primaryButtonBg: string = '#1A1A1A'
  @LocalStorageProp('primaryButtonOpacity') primaryButtonOpacity: string = '1'
  @LocalStorageProp('secondaryId') secondaryId: string = '2'
  @LocalStorageProp('secondaryName') secondaryName: string = '卧室空调'
  @LocalStorageProp('secondaryRoom') secondaryRoom: string = '卧室'
  @LocalStorageProp('secondaryParam') secondaryParam: string = '温度26°C  制冷'
  @LocalStorageProp('secondaryOnlineText') secondaryOnlineText: string = '在线'
  @LocalStorageProp('secondaryOnlineColor') secondaryOnlineColor: string = '#4CAF50'
  @LocalStorageProp('secondaryIcon') secondaryIcon: string = 'icon_ac_unit.png'
  @LocalStorageProp('secondaryButtonIcon') secondaryButtonIcon: string = 'btn_power_on.png'
  @LocalStorageProp('secondaryButtonBg') secondaryButtonBg: string = '#1A1A1A'
  @LocalStorageProp('secondaryButtonOpacity') secondaryButtonOpacity: string = '1'

  @Builder
  devicePanel(deviceId: string, name: string, room: string, param: string, onlineText: string, onlineColor: string,
    icon: string, buttonIcon: string, buttonBg: string, buttonOpacity: string) {
    Row() {
      Image($rawfile(icon))
        .width(44)
        .height(44)
        .margin({ right: 12 })

      Column() {
        Row() {
          Column() {
            Text(name)
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(room)
              .fontSize(11)
              .fontColor('#7B7F86')
              .margin({ top: 4 })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Row() {
            Image($rawfile(onlineText === '在线' ? 'dot_online.png' : 'dot_offline.png'))
              .width(8)
              .height(8)
              .margin({ right: 4 })
            Text(onlineText)
              .fontSize(11)
              .fontColor(onlineColor)
          }
        }
        .width('100%')

        Text(param)
          .fontSize(12)
          .fontColor('#6B7280')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 10 })
      }
      .layoutWeight(1)
      .onClick(() => {
        postCardAction(this, {
          action: 'router',
          abilityName: 'EntryAbility',
          params: {
            targetDeviceId: deviceId
          }
        })
      })

      Button() {
        Image($rawfile(buttonIcon))
          .width(20)
          .height(20)
      }
      .width(48)
      .height(48)
      .borderRadius(24)
      .backgroundColor(buttonBg)
      .opacity(Number(buttonOpacity))
      .margin({ left: 12 })
      .onClick(() => {
        if (onlineText === '在线') {
          postCardAction(this, {
            action: 'message',
            params: {
              operation: 'toggle',
              deviceId: deviceId
            }
          })
        }
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .borderRadius(20)
    .border({ width: 1, color: '#52FFFFFF' })
    .backgroundColor('#D9FFFFFF')
    .shadow({ radius: 12, color: '#12000000', offsetX: 0, offsetY: 4 })
  }

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

        Column({ space: 12 }) {
          this.devicePanel(this.primaryId, this.primaryName, this.primaryRoom, this.primaryParam, this.primaryOnlineText,
            this.primaryOnlineColor, this.primaryIcon, this.primaryButtonIcon, this.primaryButtonBg, this.primaryButtonOpacity)
          this.devicePanel(this.secondaryId, this.secondaryName, this.secondaryRoom, this.secondaryParam, this.secondaryOnlineText,
            this.secondaryOnlineColor, this.secondaryIcon, this.secondaryButtonIcon, this.secondaryButtonBg,
            this.secondaryButtonOpacity)
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
