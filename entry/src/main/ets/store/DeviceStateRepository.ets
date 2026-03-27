import { common } from '@kit.AbilityKit'
import { preferences } from '@kit.ArkData'
import { formBindingData, formProvider } from '@kit.FormKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { DeviceItemData } from '../model/DeviceItemData'
import { DeviceMockRepository } from '../mock/DeviceMockRepository'

const TAG: string = 'DeviceStateRepository'
const STORE_NAME: string = 'smart_home_store'
const DEVICES_KEY: string = 'devices'
const ROUND_KEY: string = 'refresh_round'
const FORM_RECORDS_KEY: string = 'form_records'
const LOAD_MORE_BATCH: number = 4

class FormRecord {
  formId: string
  formName: string

  constructor(formId: string, formName: string) {
    this.formId = formId
    this.formName = formName
  }
}

class HarmonyFormPayload {
  title: string = ''
  subtitle: string = ''
  updatedAt: string = ''
  deviceId: string = ''
  deviceName: string = ''
  deviceRoom: string = ''
  deviceParam: string = ''
  deviceOnlineText: string = ''
  deviceOnlineColor: string = ''
  deviceIcon: string = ''
  deviceButtonIcon: string = ''
  deviceButtonBg: string = ''
  deviceButtonOpacity: string = ''
  primaryId: string = ''
  primaryName: string = ''
  primaryRoom: string = ''
  primaryParam: string = ''
  primaryOnlineText: string = ''
  primaryOnlineColor: string = ''
  primaryIcon: string = ''
  primaryButtonIcon: string = ''
  primaryButtonBg: string = ''
  primaryButtonOpacity: string = ''
  secondaryId: string = ''
  secondaryName: string = ''
  secondaryRoom: string = ''
  secondaryParam: string = ''
  secondaryOnlineText: string = ''
  secondaryOnlineColor: string = ''
  secondaryIcon: string = ''
  secondaryButtonIcon: string = ''
  secondaryButtonBg: string = ''
  secondaryButtonOpacity: string = ''
}

export class DeviceStateRepository {
  static async loadDevices(context: common.Context): Promise<DeviceItemData[]> {
    await DeviceStateRepository.ensureStore(context)
    let store = await DeviceStateRepository.getStore(context)
    let value = await store.get(DEVICES_KEY, '[]') as string
    return DeviceStateRepository.restoreDevices(value)
  }

  static async refreshDevices(context: common.Context): Promise<DeviceItemData[]> {
    await DeviceStateRepository.ensureStore(context)
    let store = await DeviceStateRepository.getStore(context)
    let currentRound = Number(await store.get(ROUND_KEY, 0))
    let nextRound = currentRound + 1
    let devices = await DeviceMockRepository.getDevicesForRound(context, nextRound)
    await DeviceStateRepository.persistDevices(store, devices, nextRound)
    await DeviceStateRepository.syncRegisteredForms(context, devices)
    return devices
  }

  static async loadMoreDevices(context: common.Context, batchSize: number = LOAD_MORE_BATCH): Promise<DeviceItemData[]> {
    await DeviceStateRepository.ensureStore(context)
    let store = await DeviceStateRepository.getStore(context)
    let currentRound = Number(await store.get(ROUND_KEY, 0))
    let devices = DeviceStateRepository.restoreDevices(await store.get(DEVICES_KEY, '[]') as string)
    let nextDevices = await DeviceMockRepository.appendDevices(context, devices, currentRound, batchSize)
    await DeviceStateRepository.persistDevices(store, nextDevices, currentRound)
    await DeviceStateRepository.syncRegisteredForms(context, nextDevices)
    return nextDevices
  }

  static async toggleDevice(context: common.Context, deviceId: number): Promise<DeviceItemData[]> {
    await DeviceStateRepository.ensureStore(context)
    let store = await DeviceStateRepository.getStore(context)
    let currentRound = Number(await store.get(ROUND_KEY, 0))
    let devices = DeviceStateRepository.restoreDevices(await store.get(DEVICES_KEY, '[]') as string)
    let target = devices.find((item: DeviceItemData) => item.id === deviceId)
    if (target && target.isOnline) {
      target.isOn = !target.isOn
      DeviceMockRepository.updateDeviceAfterToggle(target)
      await DeviceStateRepository.persistDevices(store, devices, currentRound)
      await DeviceStateRepository.syncRegisteredForms(context, devices)
    }
    return devices
  }

  static async registerForm(context: common.Context, formId: string, formName: string): Promise<void> {
    await DeviceStateRepository.ensureStore(context)
    let store = await DeviceStateRepository.getStore(context)
    let records = DeviceStateRepository.restoreForms(await store.get(FORM_RECORDS_KEY, '[]') as string)
    let nextRecords = records.filter((item: FormRecord) => item.formId !== formId)
    nextRecords.push(new FormRecord(formId, formName))
    await store.put(FORM_RECORDS_KEY, JSON.stringify(nextRecords))
    await store.flush()
  }

  static async unregisterForm(context: common.Context, formId: string): Promise<void> {
    await DeviceStateRepository.ensureStore(context)
    let store = await DeviceStateRepository.getStore(context)
    let records = DeviceStateRepository.restoreForms(await store.get(FORM_RECORDS_KEY, '[]') as string)
    let nextRecords = records.filter((item: FormRecord) => item.formId !== formId)
    await store.put(FORM_RECORDS_KEY, JSON.stringify(nextRecords))
    await store.flush()
  }

  static async syncRegisteredForms(context: common.Context, devices?: DeviceItemData[]): Promise<void> {
    await DeviceStateRepository.ensureStore(context)
    let store = await DeviceStateRepository.getStore(context)
    let records = DeviceStateRepository.restoreForms(await store.get(FORM_RECORDS_KEY, '[]') as string)
    let currentDevices = devices ?? DeviceStateRepository.restoreDevices(await store.get(DEVICES_KEY, '[]') as string)
    for (let index = 0; index < records.length; index++) {
      await DeviceStateRepository.syncFormRecord(records[index], currentDevices)
    }
  }

  static createFormBinding(formName: string, devices: DeviceItemData[]): formBindingData.FormBindingData {
    let payload = DeviceStateRepository.createFormPayload(formName, devices)
    return formBindingData.createFormBindingData(payload)
  }

  static async syncForm(context: common.Context, formId: string, formName: string): Promise<void> {
    let devices = await DeviceStateRepository.loadDevices(context)
    await DeviceStateRepository.syncFormRecord(new FormRecord(formId, formName), devices)
  }

  static async ensureStore(context: common.Context): Promise<void> {
    let store = await DeviceStateRepository.getStore(context)
    let rawDevices = await store.get(DEVICES_KEY, '') as string
    if (rawDevices.length === 0) {
      let devices = await DeviceMockRepository.getInitialDevices(context)
      await DeviceStateRepository.persistDevices(store, devices, 0)
    }

    let rawForms = await store.get(FORM_RECORDS_KEY, '') as string
    if (rawForms.length === 0) {
      await store.put(FORM_RECORDS_KEY, '[]')
      await store.flush()
    }
  }

  static async getStore(context: common.Context): Promise<preferences.Preferences> {
    return preferences.getPreferences(context, STORE_NAME)
  }

  static async persistDevices(store: preferences.Preferences, devices: DeviceItemData[], round: number): Promise<void> {
    await store.put(DEVICES_KEY, JSON.stringify(devices))
    await store.put(ROUND_KEY, round)
    await store.flush()
  }

  static restoreDevices(raw: string): DeviceItemData[] {
    if (raw.length === 0) {
      return DeviceMockRepository.getFallbackDevices()
    }
    let parsed = JSON.parse(raw) as Array<Record<string, string | number | boolean>>
    let devices: DeviceItemData[] = []
    for (let index = 0; index < parsed.length; index++) {
      let item = parsed[index]
      devices.push(new DeviceItemData(
        Number(item.id),
        String(item.name),
        String(item.icon),
        Boolean(item.isOnline),
        Boolean(item.isOn),
        String(item.paramLabel),
        String(item.type) as 'power' | 'play',
        String(item.room),
        String(item.category)
      ))
    }
    return devices
  }

  static restoreForms(raw: string): FormRecord[] {
    if (raw.length === 0) {
      return []
    }
    let parsed = JSON.parse(raw) as Array<Record<string, string>>
    let records: FormRecord[] = []
    for (let index = 0; index < parsed.length; index++) {
      records.push(new FormRecord(String(parsed[index].formId), String(parsed[index].formName)))
    }
    return records
  }

  static async syncFormRecord(record: FormRecord, devices: DeviceItemData[]): Promise<void> {
    try {
      let formData = DeviceStateRepository.createFormBinding(record.formName, devices)
      await formProvider.updateForm(record.formId, formData)
    } catch (error) {
      hilog.error(0x0000, TAG, `updateForm failed: ${JSON.stringify(error)}`)
    }
  }

  static createFormPayload(formName: string, devices: DeviceItemData[]): HarmonyFormPayload {
    let featured = DeviceStateRepository.getFeaturedDevices(devices)
    let first = featured[0]
    let second = featured[1]
    if (formName === 'HarmonyDeviceCard2x2') {
      return DeviceStateRepository.createSingleCardPayload(first, devices.length)
    }
    return DeviceStateRepository.createDoubleCardPayload(first, second, devices.length)
  }

  static createSingleCardPayload(device: DeviceItemData, total: number): HarmonyFormPayload {
    let payload = new HarmonyFormPayload()
    payload.title = 'Harmony 智能家居'
    payload.subtitle = `已连接 ${total} 台设备`
    payload.updatedAt = DeviceStateRepository.formatUpdateTime()
    payload.deviceId = device.id.toString()
    payload.deviceName = device.name
    payload.deviceRoom = device.room
    payload.deviceParam = device.paramLabel
    payload.deviceOnlineText = device.isOnline ? '在线' : '离线'
    payload.deviceOnlineColor = device.isOnline ? '#4CAF50' : '#9E9E9E'
    payload.deviceIcon = device.icon
    payload.deviceButtonIcon = DeviceStateRepository.getButtonIcon(device)
    payload.deviceButtonBg = DeviceStateRepository.getButtonBackground(device)
    payload.deviceButtonOpacity = device.isOnline ? '1' : '0.4'
    return payload
  }

  static createDoubleCardPayload(first: DeviceItemData, second: DeviceItemData, total: number): HarmonyFormPayload {
    let payload = new HarmonyFormPayload()
    payload.title = 'Harmony 智能家居'
    payload.subtitle = `桌面联动中 · ${total} 台设备`
    payload.updatedAt = DeviceStateRepository.formatUpdateTime()
    payload.primaryId = first.id.toString()
    payload.primaryName = first.name
    payload.primaryRoom = first.room
    payload.primaryParam = first.paramLabel
    payload.primaryOnlineText = first.isOnline ? '在线' : '离线'
    payload.primaryOnlineColor = first.isOnline ? '#4CAF50' : '#9E9E9E'
    payload.primaryIcon = first.icon
    payload.primaryButtonIcon = DeviceStateRepository.getButtonIcon(first)
    payload.primaryButtonBg = DeviceStateRepository.getButtonBackground(first)
    payload.primaryButtonOpacity = first.isOnline ? '1' : '0.4'
    payload.secondaryId = second.id.toString()
    payload.secondaryName = second.name
    payload.secondaryRoom = second.room
    payload.secondaryParam = second.paramLabel
    payload.secondaryOnlineText = second.isOnline ? '在线' : '离线'
    payload.secondaryOnlineColor = second.isOnline ? '#4CAF50' : '#9E9E9E'
    payload.secondaryIcon = second.icon
    payload.secondaryButtonIcon = DeviceStateRepository.getButtonIcon(second)
    payload.secondaryButtonBg = DeviceStateRepository.getButtonBackground(second)
    payload.secondaryButtonOpacity = second.isOnline ? '1' : '0.4'
    return payload
  }

  static getFeaturedDevices(devices: DeviceItemData[]): DeviceItemData[] {
    let source = devices.filter((item: DeviceItemData) => item.isOnline)
    if (source.length < 2) {
      source = devices
    }
    if (source.length === 0) {
      let fallback = DeviceMockRepository.getFallbackDevices()
      return [fallback[0], fallback[1]]
    }
    if (source.length === 1) {
      return [source[0], source[0]]
    }
    return [source[0], source[1]]
  }

  static getButtonIcon(device: DeviceItemData): string {
    if (!device.isOnline) {
      return 'btn_power_off.png'
    }
    if (device.type === 'play') {
      return device.isOn ? 'btn_pause.png' : 'btn_play.png'
    }
    return device.isOn ? 'btn_power_on.png' : 'btn_power_off.png'
  }

  static getButtonBackground(device: DeviceItemData): string {
    if (!device.isOnline) {
      return '#22FFFFFF'
    }
    return device.isOn ? '#1A1A1A' : '#F4F5F7'
  }

  static formatUpdateTime(): string {
    let now = new Date()
    let hour = `${now.getHours()}`.padStart(2, '0')
    let minute = `${now.getMinutes()}`.padStart(2, '0')
    return `最近更新 ${hour}:${minute}`
  }
}
