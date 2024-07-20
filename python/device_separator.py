device_list = []
projectors = []
with open("python/known_devices.txt") as all_dev:
    device_list = all_dev.readlines()

for device in device_list:
    dev_info = device.strip().split()
    print(dev_info)
    try:
        if dev_info[1] == "TV":
            with open("assets/brands_TV.txt", "a") as place:
                place.write(f"{dev_info[0]}\n")
        elif dev_info[1] == "Projector" or dev_info[1] == "Video":
            if not dev_info[0] in projectors:
                projectors.append(dev_info[0])
                with open("assets/brands_projector.txt", "a") as place:
                        place.write(f"{dev_info[0]}\n")
        else:
            with open("assets/brands_ac.txt", "a") as place:
                        place.write(f"{dev_info[0]}\n")
    except IndexError:
        pass