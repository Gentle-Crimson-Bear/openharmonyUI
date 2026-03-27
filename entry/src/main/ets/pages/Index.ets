// 智能家居设备控制面板 - 严格对齐设计稿
import { promptAction } from '@kit.ArkUI'
import { DeviceItemData } from '../model/DeviceItemData'
import { DeviceMockRepository } from '../mock/DeviceMockRepository'

const PHONE_PADDING: number = 16
const LANDSCAPE_PADDING: number = 20
const TABLET_PADDING: number = 24
const PHONE_LIST_SPACE: number = 12
const TABLET_LIST_SPACE: number = 16
const TABLET_BREAKPOINT: number = 840

// ===== 设备卡片组件（独立封装，可复用） =====
@Component
struct DeviceCard {
  @ObjectLink device: DeviceItemData
  isTabletLayout: boolean = false
  onToggle: () => void = () => {}

  build() {
    Row() {
      // 左侧：设备图标
      Image($rawfile(this.device.icon))
        .width(this.getIconSize())
        .height(this.getIconSize())
        .objectFit(ImageFit.Contain)
        .margin({ right: 12 })

      // 中间：名称 + 参数
      Column() {
        // 第一行：设备名称 + 在线状态
        Row() {
          Text(this.device.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1A1A1A')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)

          // 在线状态
          Row() {
            Image($rawfile(this.device.isOnline ? 'dot_online.png' : 'dot_offline.png'))
              .width(8)
              .height(8)
              .margin({ right: 4 })
            Text(this.device.isOnline ? '在线' : '离线')
              .fontSize(12)
              .fontColor(this.device.isOnline ? '#4CAF50' : '#9E9E9E')
          }
        }
        .width('100%')

        // 参数文本
        Text(this.device.paramLabel)
          .fontSize(13)
          .fontColor('#999999')
          .margin({ top: 8 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)

      // 右侧：控制按钮
      Image($rawfile(this.getButtonIcon()))
        .width(this.getActionSize())
        .height(this.getActionSize())
        .objectFit(ImageFit.Contain)
        .margin({ left: 12 })
        .opacity(this.device.isOnline ? 1.0 : 0.4)
        .enabled(this.device.isOnline)
        .onClick(() => {
          if (this.device.isOnline) {
            this.onToggle()
          }
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: this.getVerticalPadding(), bottom: this.getVerticalPadding() })
    .borderRadius(20)
    .backdropBlur(60)
    .backgroundColor('#B3FFFFFF')  // 半透明白色毛玻璃效果
    .shadow({
      radius: 16,
      color: '#1A000000',
      offsetX: 0,
      offsetY: 4
    })
  }

  getIconSize(): number {
    return this.isTabletLayout ? 64 : 60
  }

  getActionSize(): number {
    return this.isTabletLayout ? 44 : 40
  }

  getVerticalPadding(): number {
    return this.isTabletLayout ? 22 : 20
  }

  getButtonIcon(): string {
    if (!this.device.isOnline) {
      return this.device.type === 'play' ? 'btn_power_off.png' : 'btn_power_off.png'
    }
    if (this.device.type === 'play') {
      return this.device.isOn ? 'btn_pause.png' : 'btn_play.png'
    }
    return this.device.isOn ? 'btn_power_on.png' : 'btn_power_off.png'
  }
}

// ===== 主页面 =====
@Entry
@Component
struct Index {
  @State devices: DeviceItemData[] = DeviceMockRepository.getInitialDevices()
  @State isRefreshing: boolean = false
  @State refreshRound: number = 0
  @State laneCount: number = 1
  @State pagePadding: number = PHONE_PADDING
  @State listSpace: number = PHONE_LIST_SPACE
  @State titleFontSize: number = 24
  @State titleTopPadding: number = 12
  @State isTabletLayout: boolean = false

  build() {
    Stack() {
      // 背景图
      Image($rawfile('bg.png'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)

      // 内容层
      Column() {
        // 标题
        Text('我的智能设备')
          .fontSize(this.titleFontSize)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .width('100%')
          .padding({ top: this.titleTopPadding, bottom: 16 })

        Text(`已连接 ${this.devices.length} 台设备`)
          .fontSize(14)
          .fontColor('#5F6368')
          .width('100%')
          .margin({ bottom: 14 })

        // 设备卡片列表 - 支持下拉刷新
        Refresh({ refreshing: $$this.isRefreshing }) {
          List({ space: this.listSpace }) {
            ForEach(this.devices, (device: DeviceItemData) => {
              ListItem() {
                DeviceCard({
                  device: device,
                  isTabletLayout: this.isTabletLayout,
                  onToggle: () => {
                    this.toggleDevice(device)
                  }
                })
              }
            }, (device: DeviceItemData) => device.id.toString())
          }
          .width('100%')
          .padding({ bottom: 20 })
          .lanes(this.laneCount)
        }
        .onRefreshing(() => {
          setTimeout(() => {
            this.refreshRound += 1
            this.devices = DeviceMockRepository.getDevicesForRound(this.refreshRound)
            this.isRefreshing = false
            promptAction.showToast({
              message: `设备状态已刷新，当前共${this.devices.length}台设备`,
              duration: 2000
            })
          }, 1200)
        })
        .layoutWeight(1)
      }
      .padding({ left: this.pagePadding, right: this.pagePadding })
      .width('100%')
      .height('100%')
      .onAreaChange((_, value) => {
        this.updateResponsiveLayout(value.width, value.height)
      })
    }
    .width('100%')
    .height('100%')
  }

  normalizeSize(value: Length): number {
    if (typeof value === 'number') {
      return value > 0 ? value : 0
    }
    if (typeof value === 'string') {
      const size: number = parseFloat(value)
      return size > 0 ? size : 0
    }
    return 0
  }

  updateResponsiveLayout(widthValue: Length, heightValue: Length) {
    const width: number = this.normalizeSize(widthValue)
    const height: number = this.normalizeSize(heightValue)
    if (width === 0 || height === 0) {
      return
    }

    const isLandscape: boolean = width > height
    const isTablet: boolean = Math.min(width, height) >= TABLET_BREAKPOINT || width >= 1024

    this.laneCount = isLandscape ? 2 : 1
    this.pagePadding = isTablet ? TABLET_PADDING : (isLandscape ? LANDSCAPE_PADDING : PHONE_PADDING)
    this.listSpace = isTablet ? TABLET_LIST_SPACE : PHONE_LIST_SPACE
    this.titleFontSize = isTablet ? 28 : 24
    this.titleTopPadding = isTablet ? 20 : 12
    this.isTabletLayout = isTablet
  }

  toggleDevice(device: DeviceItemData) {
    device.isOn = !device.isOn
    DeviceMockRepository.updateDeviceAfterToggle(device)
    promptAction.showToast({
      message: `${device.name}状态已更新`,
      duration: 3000
    })
  }
}
