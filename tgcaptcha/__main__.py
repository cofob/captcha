from telethon import TelegramClient, Button, events
from datetime import timedelta
from hashlib import sha256
from asyncio import sleep
from time import time
from os import environ

client = TelegramClient("bot", environ["API_ID"], environ["API_HASH"]).start(bot_token=environ["TOKEN"])
unverifed = []
me = None


async def prepare():
    global me
    me = await client.get_me()


def get_hash(text):
    return sha256((environ["SECRET"] + str(text) + str(int(time() / 300))).encode()).hexdigest()[:10]


@client.on(events.ChatAction(func=lambda e: e.user_joined))
async def new_user(event):
    chat, user = await event.get_chat(), await event.get_user()
    unverifed.append(user.id)
    keyboard = [[Button.url("Пройти", f"https://t.me/{me.username}?start={chat.id}-{get_hash(user.id)}")]]
    await client.edit_permissions(chat, user, timedelta(minutes=1), send_messages=False)
    msg = await event.reply(f"Привет! Пройди каптчу чтобы продолжить. У тебя есть 30 секунд.", buttons=keyboard)
    await sleep(30)
    if user.id in unverifed:
        unverifed.remove(user.id)
        await client.kick_participant(chat, user)
        await client.send_message(user, "Я кикнул тебя из чата так как ты не успел пройти каптчу за 30 секунд.")
    await msg.delete()


@client.on(events.NewMessage(func=lambda e: e.is_private))
async def private(event):
    try:
        start = event.text.split()[1]
        chat_id = start.split("-")[0]
        key = start.split("-")[1]
    except IndexError:
        return await event.reply(
            "Привет! Это простой бот-каптча который просит пользователей нажать на кнопку старт. Исходники - https://git.averyan.ru/cofob/captcha"
        )
    user = await client.get_entity(event.peer_id)
    chat = await client.get_entity(int(chat_id))
    valid_key = get_hash(user.id)
    if key == valid_key:
        unverifed.remove(user.id)
        await client.edit_permissions(chat, user, send_messages=True)
        await event.reply("Вы прошли каптчу! Прочитайте правила в закреплённом сообщении. Приятного общения.")
    else:
        await event.reply("Авторизация не пройдена, перезайдите в чат и попробуйте снова.")


def main():
    client.start()
    client.loop.run_until_complete(prepare())
    client.run_until_disconnected()


if __name__ == "__main__":
    main()
