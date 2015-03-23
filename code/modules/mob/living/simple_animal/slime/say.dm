/mob/living/simple_animal/slime/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "telepathically asks, \"[text]\"";
	else if (ending == "!")
		return "telepathically cries, \"[text]\"";

	return "telepathically chirps, \"[text]\"";

/mob/living/simple_animal/slime/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans)	if(speaker != src && !radio_freq)
		if (speaker in Friends)
			speech_buffer = list()
			speech_buffer += speaker
			speech_buffer += lowertext(html_decode(message))
	..()
