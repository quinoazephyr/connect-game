let sounds = [];
function LoadSounds(sounds_paths) {
	sounds_paths.forEach(function(path) {
		var sound = new Howl({
			src: [path]
		});
		sounds.push(sound);
	});
}

function PlaySound(sound_idx) {
	var sound = sounds[sound_idx];
	sound.play();
}

function MuteSound(sound_idx, is_muted) {
	var sound = sounds[sound_idx];
	sound.mute(is_muted);
}

function MuteAllSounds(is_muted) {
	Howler.mute(is_muted);
}