import { DeviceItemData } from '../model/DeviceItemData'

class DeviceSeed {
  id: number
  name: string
  icon: string
  room: string
  category: string
  type: 'power' | 'play'
  defaultOn: boolean

  constructor(id: number, name: string, icon: string, room: string, category: string,
    type: 'power' | 'play', defaultOn: boolean) {
    this.id = id
    this.name = name
    this.icon = icon
    this.room = room
    this.category = category
    this.type = type
    this.defaultOn = defaultOn
  }
}

export class DeviceMockRepository {
  static readonly seeds: DeviceSeed[] = [
    new DeviceSeed(1, '客厅主灯', 'icon_light.png', '客厅', 'light', 'power', true),
    new DeviceSeed(2, '卧室空调', 'icon_ac_unit.png', '卧室', 'ac', 'power', true),
    new DeviceSeed(3, '客厅窗帘', 'icon_curtain.png', '客厅', 'curtain', 'power', false),
    new DeviceSeed(4, '扫地机器人', 'icon_robot.png', '全屋', 'robot', 'play', true),
    new DeviceSeed(5, '玄关门锁', 'icon_ac.png', '玄关', 'lock', 'power', true),
    new DeviceSeed(6, '儿童房加湿器', 'icon_ac.png', '儿童房', 'humidifier', 'power', true),
    new DeviceSeed(7, '餐厅音箱', 'icon_light.png', '餐厅', 'speaker', 'play', false),
    new DeviceSeed(8, '阳台摄像头', 'icon_robot.png', '阳台', 'camera', 'power', true),
  ]

  static getInitialDevices(): DeviceItemData[] {
    return DeviceMockRepository.getDevicesForRound(0)
  }

  static getDevicesForRound(round: number): DeviceItemData[] {
    let visibleCount: number = DeviceMockRepository.getVisibleCount(round)
    let result: DeviceItemData[] = []
    for (let index = 0; index < visibleCount; index++) {
      result.push(DeviceMockRepository.createDevice(DeviceMockRepository.seeds[index], round))
    }
    return result
  }

  static updateDeviceAfterToggle(device: DeviceItemData): void {
    device.paramLabel = DeviceMockRepository.buildParamLabel(device.category, device.id, 0, device.isOnline, device.isOn)
  }

  static getVisibleCount(round: number): number {
    let stage: number = round % 4
    if (stage === 1) {
      return 7
    }
    if (stage === 2) {
      return 8
    }
    return 6
  }

  static createDevice(seed: DeviceSeed, round: number): DeviceItemData {
    let isOnline: boolean = (seed.id + round) % 5 !== 0
    let isOn: boolean = isOnline ? DeviceMockRepository.getSwitchState(seed, round) : false
    let paramLabel: string = DeviceMockRepository.buildParamLabel(seed.category, seed.id, round, isOnline, isOn)
    return new DeviceItemData(
      seed.id,
      seed.name,
      seed.icon,
      isOnline,
      isOn,
      paramLabel,
      seed.type,
      seed.room,
      seed.category
    )
  }

  static getSwitchState(seed: DeviceSeed, round: number): boolean {
    if (seed.category === 'light' || seed.category === 'ac' || seed.category === 'humidifier' || seed.category === 'camera') {
      return (seed.id + round) % 3 !== 0
    }
    if (seed.category === 'curtain' || seed.category === 'speaker') {
      return (seed.id + round) % 2 === 0
    }
    return seed.defaultOn
  }

  static buildParamLabel(category: string, id: number, round: number, isOnline: boolean, isOn: boolean): string {
    let baseLabel: string = ''
    if (category === 'light') {
      let brightness: number = isOn ? 55 + (round * 9 + id * 7) % 40 : 0
      baseLabel = `亮度${brightness}%`
    } else if (category === 'ac') {
      let temperature: number = isOn ? 24 + (round + id) % 4 : 28
      let mode: string = isOn ? ((round + id) % 2 === 0 ? '制冷' : '除湿') : '待机'
      baseLabel = `温度${temperature}°C  ${mode}`
    } else if (category === 'curtain') {
      let position: number = isOn ? 30 + (round * 11 + id * 5) % 65 : 0
      baseLabel = `开合${position}%`
    } else if (category === 'robot') {
      let battery: number = 58 + (round * 7 + id * 6) % 38
      let status: string = isOn ? '清洁中' : '已暂停'
      baseLabel = `电量${battery}%  ${status}`
    } else if (category === 'lock') {
      let battery: number = 72 + (round * 5 + id * 3) % 24
      let status: string = isOn ? '已上锁' : '未上锁'
      baseLabel = `电量${battery}%  ${status}`
    } else if (category === 'humidifier') {
      let humidity: number = isOn ? 46 + (round * 4 + id * 3) % 22 : 40 + (round + id) % 6
      let status: string = isOn ? '自动' : '待机'
      baseLabel = `湿度${humidity}%  ${status}`
    } else if (category === 'speaker') {
      let volume: number = isOn ? 24 + (round * 6 + id * 5) % 48 : 0
      let status: string = isOn ? '播放中' : '已暂停'
      baseLabel = `音量${volume}%  ${status}`
    } else {
      let quality: string = isOn ? '1080P' : '待机'
      let status: string = isOn ? '侦测中' : '画面关闭'
      baseLabel = `${quality}  ${status}`
    }

    return isOnline ? baseLabel : `${baseLabel}  设备离线`
  }
}
