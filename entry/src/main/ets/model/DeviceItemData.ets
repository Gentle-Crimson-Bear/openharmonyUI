@Observed
export class DeviceItemData {
  id: number
  name: string
  icon: string
  isOnline: boolean
  isOn: boolean
  paramLabel: string
  type: 'power' | 'play'
  room: string
  category: string

  constructor(id: number, name: string, icon: string, isOnline: boolean, isOn: boolean,
    paramLabel: string, type: 'power' | 'play', room: string, category: string) {
    this.id = id
    this.name = name
    this.icon = icon
    this.isOnline = isOnline
    this.isOn = isOn
    this.paramLabel = paramLabel
    this.type = type
    this.room = room
    this.category = category
  }
}
