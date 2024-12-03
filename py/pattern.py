import csv

# Data
data = [
    (8500, 0.002), (8410, 0.046), (8320, 0.124), (8311, 0.092), (7600, 0.004),
    (7510, 0.1), (7420, 0.364), (7411, 0.362), (7330, 0.264), (7321, 1.944),
    (7510, 0.1), (7420, 0.364), (7411, 0.362), (7330, 0.264), (7321, 1.944),
    (6610, 0.078), (6520, 0.586), (6511, 0.642), (6430, 1.292), (6421, 4.688),
    (5440, 1.208), (5431, 13.096), (5422, 10.63), (5332, 15.532), (4441, 3.028),
    (4432, 21.81), (4333, 10.478)
]

# Write to CSV
with open('pattern.csv', mode='w', newline='') as file:
    writer = csv.writer(file)
    # Write header
    writer.writerow(['Pattern', '%'])
    # Write data
    writer.writerows(data)

print("Data written to pattern.csv")
