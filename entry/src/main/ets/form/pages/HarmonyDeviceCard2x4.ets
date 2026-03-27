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
  devicePanel(deviceId: string, name: string, param: string, onlineText: string, icon: string,
    buttonIcon: string, buttonBg: string, buttonOpacity: string) {
    Row() {
      Image($rawfile(icon))
        .width(36)
        .height(36)
        .objectFit(ImageFit.Contain)
        .margin({ right: 10 })

      Column() {
        Row() {
          Text(name)
            .layoutWeight(1)
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Image($rawfile(onlineText === '在线' ? 'dot_online.png' : 'dot_offline.png'))
            .width(8)
            .height(8)
            .margin({ left: 6 })
        }
        .width('100%')

        Text(param)
          .width('100%')
          .fontSize(9)
          .fontColor('#6B7280')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 6 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .onClick(() => {
        this.routeToDevice(deviceId)
      })

      Button() {
        Image($rawfile(buttonIcon))
          .width(16)
          .height(16)
      }
      .width(36)
      .height(36)
      .borderRadius(18)
      .backgroundColor(buttonBg)
      .opacity(Number(buttonOpacity))
      .margin({ left: 10 })
      .onClick(() => {
        this.postToggleAction(deviceId, onlineText)
      })
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
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

      Column({ space: 8 }) {
        Text('智能家居')
          .width('100%')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Column({ space: 8 }) {
          this.devicePanel(this.primaryId, this.primaryName, this.primaryParam, this.primaryOnlineText,
            this.primaryIcon, this.primaryButtonIcon, this.primaryButtonBg, this.primaryButtonOpacity)
          this.devicePanel(this.secondaryId, this.secondaryName, this.secondaryParam, this.secondaryOnlineText,
            this.secondaryIcon, this.secondaryButtonIcon, this.secondaryButtonBg, this.secondaryButtonOpacity)
        }
        .width('100%')
        .layoutWeight(1)
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

  routeToDevice(deviceId: string): void {
    postCardAction(this, {
      action: 'router',
      abilityName: 'EntryAbility',
      params: {
        targetDeviceId: deviceId
      }
    })
  }

  postToggleAction(deviceId: string, onlineText: string): void {
    if (onlineText !== '在线') {
      return
    }
    postCardAction(this, {
      action: 'message',
      params: {
        operation: 'toggle',
        deviceId: deviceId
      }
    })
  }
}
