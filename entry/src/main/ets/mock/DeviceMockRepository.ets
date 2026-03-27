import { common } from '@kit.AbilityKit'
import { util } from '@kit.ArkTS'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { DeviceItemData } from '../model/DeviceItemData'

const TAG: string = 'DeviceMockRepository'
const MOCK_FILE_PATH: string = 'mock/devices.mock.json'
const DEVICE_ID_SPAN: number = 1000
const DEFAULT_VISIBLE_COUNT: number = 6

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
  static readonly fallbackSeeds: DeviceSeed[] = [
    new DeviceSeed(1, '客厅主灯', 'icon_light.png', '客厅', 'light', 'power', true),
    new DeviceSeed(2, '卧室空调', 'icon_ac_unit.png', '卧室', 'ac', 'power', true),
    new DeviceSeed(3, '客厅窗帘', 'icon_curtain.png', '客厅', 'curtain', 'power', false),
    new DeviceSeed(4, '扫地机器人', 'icon_robot.png', '全屋', 'robot', 'play', true),
    new DeviceSeed(5, '玄关门锁', 'icon_ac.png', '玄关', 'lock', 'power', true),
    new DeviceSeed(6, '儿童房加湿器', 'icon_ac.png', '儿童房', 'humidifier', 'power', true),
    new DeviceSeed(7, '餐厅音箱', 'icon_light.png', '餐厅', 'speaker', 'play', false),
    new DeviceSeed(8, '阳台摄像头', 'icon_robot.png', '阳台', 'camera', 'power', true),
  ]

  static cachedSeeds: DeviceSeed[] = DeviceMockRepository.fallbackSeeds

  static async getInitialDevices(context?: common.Context): Promise<DeviceItemData[]> {
    return DeviceMockRepository.getDevicesForRound(context, 0)
  }

  static getFallbackDevices(): DeviceItemData[] {
    return DeviceMockRepository.buildDevices(
      DeviceMockRepository.cachedSeeds,
      0,
      DeviceMockRepository.getVisibleCount(0, DeviceMockRepository.cachedSeeds.length)
    )
  }

  static async getDevicesForRound(context: common.Context | undefined, round: number): Promise<DeviceItemData[]> {
    let seeds = await DeviceMockRepository.loadSeeds(context)
    let visibleCount: number = DeviceMockRepository.getVisibleCount(round, seeds.length)
    return DeviceMockRepository.buildDevices(seeds, round, visibleCount)
  }

  static async appendDevices(context: common.Context | undefined, currentDevices: DeviceItemData[],
    round: number, appendCount: number): Promise<DeviceItemData[]> {
    let seeds = await DeviceMockRepository.loadSeeds(context)
    let targetCount: number = currentDevices.length + appendCount
    return DeviceMockRepository.buildDevices(seeds, round, targetCount)
  }

  static updateDeviceAfterToggle(device: DeviceItemData): void {
    let seedId: number = DeviceMockRepository.getSeedId(device.id)
    let deviceRound: number = DeviceMockRepository.getSeedCycle(device.id)
    device.paramLabel = DeviceMockRepository.buildParamLabel(device.category, seedId + deviceRound * 17, deviceRound,
      device.isOnline, device.isOn)
  }

  static async loadSeeds(context?: common.Context): Promise<DeviceSeed[]> {
    if (!context) {
      return DeviceMockRepository.cachedSeeds
    }
    try {
      let rawData: Uint8Array = context.resourceManager.getRawFileContentSync(MOCK_FILE_PATH)
      let content: string = util.TextDecoder.create('utf-8', { ignoreBOM: true }).decodeWithStream(rawData)
      let parsed = JSON.parse(content) as Record<string, Array<Record<string, string | number | boolean>>>
      let seeds: DeviceSeed[] = DeviceMockRepository.parseSeeds(parsed['devices'])
      if (seeds.length > 0) {
        DeviceMockRepository.cachedSeeds = seeds
      }
    } catch (error) {
      hilog.warn(0x0000, TAG, `load mock file failed: ${JSON.stringify(error)}`)
    }
    return DeviceMockRepository.cachedSeeds
  }

  static parseSeeds(items: Array<Record<string, string | number | boolean>> | undefined): DeviceSeed[] {
    if (!items || items.length === 0) {
      return DeviceMockRepository.fallbackSeeds
    }
    let seeds: DeviceSeed[] = []
    for (let index = 0; index < items.length; index++) {
      let item = items[index]
      let rawId: number = Number(item['id'])
      let id: number = rawId > 0 ? rawId : index + 1
      let type: 'power' | 'play' = String(item['type']) === 'play' ? 'play' : 'power'
      seeds.push(new DeviceSeed(
        id,
        String(item['name']),
        String(item['icon']),
        String(item['room']),
        String(item['category']),
        type,
        Boolean(item['defaultOn'])
      ))
    }
    return seeds.length > 0 ? seeds : DeviceMockRepository.fallbackSeeds
  }

  static getVisibleCount(round: number, seedCount: number): number {
    let total: number = seedCount > 0 ? seedCount : DeviceMockRepository.fallbackSeeds.length
    let stage: number = round % 4
    if (stage === 1) {
      return Math.min(total, 7)
    }
    if (stage === 2) {
      return Math.min(total, 8)
    }
    return Math.min(total, DEFAULT_VISIBLE_COUNT)
  }

  static buildDevices(seeds: DeviceSeed[], round: number, count: number): DeviceItemData[] {
    let source: DeviceSeed[] = seeds.length > 0 ? seeds : DeviceMockRepository.fallbackSeeds
    let result: DeviceItemData[] = []
    for (let index = 0; index < count; index++) {
      let seed: DeviceSeed = source[index % source.length]
      let cycle: number = Math.floor(index / source.length)
      result.push(DeviceMockRepository.createDevice(seed, round, cycle))
    }
    return result
  }

  static createDevice(seed: DeviceSeed, round: number, cycle: number): DeviceItemData {
    let seedId: number = seed.id + cycle * 17
    let deviceId: number = cycle * DEVICE_ID_SPAN + seed.id
    let effectRound: number = round + cycle
    let isOnline: boolean = (seedId + effectRound) % 5 !== 0
    let isOn: boolean = isOnline ? DeviceMockRepository.getSwitchState(seed, effectRound) : false
    let paramLabel: string = DeviceMockRepository.buildParamLabel(seed.category, seedId, effectRound, isOnline, isOn)
    let name: string = cycle === 0 ? seed.name : `${seed.name}${cycle + 1}号`
    let room: string = cycle === 0 ? seed.room : `${seed.room}${cycle + 1}区`
    return new DeviceItemData(
      deviceId,
      name,
      seed.icon,
      isOnline,
      isOn,
      paramLabel,
      seed.type,
      room,
      seed.category
    )
  }

  static getSeedCycle(deviceId: number): number {
    return Math.floor(deviceId / DEVICE_ID_SPAN)
  }

  static getSeedId(deviceId: number): number {
    let seedId: number = deviceId % DEVICE_ID_SPAN
    return seedId > 0 ? seedId : deviceId
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
