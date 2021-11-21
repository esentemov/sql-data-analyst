# Дан массив целых чисел nums и целое число target. Написать функцию,
# возвращающую индексы элементов, дающих в сумме число target?


def sum_index(nums: int, target: int):
    index = []
    for i in range(len(nums)):
        for j in range(i + 1, len(nums)):
            sum = nums[i] + nums[j]
            if sum == target:
                index.append(i)
                index.append(j)    # Добавляем подходящие пары
    if index == []:
        return 'Нет подходящих вариантов'
    else:
        return index

#тест
print(sum_index(nums=[1, 2, 3, 4, 5, 6, 7], target = 4))
