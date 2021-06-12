# Dotfiles

## Setup
Clone Repository in Home Folder and run `~/dotfiles/setup`


## Battery (macOS)
- Set `BATTERY_LOG_PATH=""` in `~/.zshrc` where you want to save battery logs.
- `$ batterylog` will log your battery status in csv.
- `$ showbatterylog [n]` will show last n battery logs. Default 5.

### Instructions for adding this in cronjob
- Add below line in crontab using `$ crontab -e`
```
0 */6 * * * ~/dotfiles/utils/battery.sh -r "$HOME/battery.csv" >/dev/null 2>&1
```
- Check if it's active `$ crontab -l`


## Plugins
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions): Searches your history while you type and provides suggestions.