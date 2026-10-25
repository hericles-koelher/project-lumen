// Native motion preview. Reuse the existing wordmark and generated halo texture.
// Defaults are inserted from the Godot tuning Resource when building the preview.
const title = document.getElementById('title');
const titleHalo = document.getElementById('titleHalo');
const status = document.getElementById('status');
const pause = document.getElementById('pause');
const compare = document.getElementById('compare');
const defaults = __DEFAULTS__;
const blinkDuration = 0.08;
const haloFadeDuration = 0.25;
const fields = {
    initialCount: ['initialCount', 'title_initial_blink_count', 0, 8, true],
    initialGap: ['initialGap', 'title_initial_blink_interval_ms', 20, 2000, false],
};
for (const [id, property] of Object.values(fields)) {
    document.getElementById(id).value = defaults[property];
}
let elapsed = 0, last = null, paused = false, steady = false;
let intensity = defaults.title_startup_intensity_percent / 100;
let haloIntensity = defaults.title_lamp_halo_intensity_percent / 100;
let timeline, lastLabel = '';
for (const [id, value, output] of [
    ['intensity', intensity, 'value'], ['haloIntensity', haloIntensity, 'haloValue'],
]) {
    document.getElementById(id).value = value * 100;
    document.getElementById(output).value = value * 100 + '%';
}

// The interval is the rest after one 80 ms blink ends, before the next begins.
function buildTimeline(config) {
    const keys = [];
    let time = config.initialCount > 0 ? 0.04 : 0;
    keys.push([0, config.initialCount > 0 ? 0.22 : 1]);
    for (let index = 0; index < config.initialCount; index++) {
        const peak = index % 2 ? 0.78 : 0.96;
        keys.push([time, 0.22], [time + 0.02, peak],
            [time + 0.05, peak], [time + blinkDuration, 0.22]);
        time += blinkDuration;
        if (index < config.initialCount - 1) time += config.initialGap / 1000;
    }
    if (config.initialCount > 0) time += 0.06;
    keys.push([time, 1], [time, 1], [time + haloFadeDuration, 1]);
    return { keys, settledAt: time, duration: time + haloFadeDuration };
}

function readConfiguration() {
    const config = {};
    for (const [name, [id, property, min, max, integer]] of Object.entries(fields)) {
        const field = document.getElementById(id);
        let value = field.value === '' ? defaults[property] : Number(field.value);
        if (!Number.isFinite(value)) value = defaults[property];
        value = Math.max(min, Math.min(max, value));
        config[name] = integer ? Math.trunc(value) : value;
        field.value = config[name];
    }
    return config;
}

function restart() {
    const config = readConfiguration();
    timeline = buildTimeline(config);
    elapsed = 0; last = null; paused = false; steady = false;
    pause.textContent = 'Pause animation'; pause.setAttribute('aria-pressed', 'false');
    compare.textContent = 'Show steady title'; compare.setAttribute('aria-pressed', 'false');
    document.getElementById('summary').textContent =
        `${config.initialCount} initial blinks · ${config.initialGap} ms gaps · strong lamp halo`;
    document.getElementById('timing').textContent =
        `Title fully lit at ${timeline.settledAt.toFixed(2)} s; halo fully visible at ${timeline.duration.toFixed(2)} s.`;
}

function level(time) {
    for (let index = 1; index < timeline.keys.length; index++) {
        const a = timeline.keys[index - 1], b = timeline.keys[index];
        if (time <= b[0]) {
            if (b[0] === a[0]) return b[1];
            let fraction = Math.max(0, Math.min(1, (time - a[0]) / (b[0] - a[0])));
            fraction = fraction * fraction * (3 - 2 * fraction);
            return a[1] + (b[1] - a[1]) * fraction;
        }
    }
    return 1;
}

function draw(now) {
    if (last !== null && !paused) {
        elapsed = Math.min(timeline.duration, elapsed + Math.min((now - last) / 1000, 0.1));
    }
    last = now;
    title.style.filter = `brightness(${steady ? 1 : Math.max(0.08, 1 - (1 - level(elapsed)) * intensity)})`;
    let halo = Math.max(0, Math.min(1, (elapsed - timeline.settledAt) / haloFadeDuration));
    halo = halo * halo * (3 - 2 * halo);
    titleHalo.style.opacity = steady ? 0 : Math.min(1, 0.20 * haloIntensity * halo);
    titleHalo.style.transform = `translate(-50%, -50%) scale(${0.90 + 0.10 * halo})`;
    const phase = elapsed < timeline.settledAt ? 'Initial flickers' :
        elapsed < timeline.duration ? 'Lamp lighting up' : 'Title and lamp halo on · Startup complete';
    const label = steady ? 'Comparison · Original steady title' : paused ? 'Startup paused' : phase;
    if (label !== lastLabel) { status.textContent = label; lastLabel = label; }
    requestAnimationFrame(draw);
}

document.getElementById('replay').onclick = restart;
for (const [id] of Object.values(fields)) document.getElementById(id).onchange = restart;
pause.onclick = () => {
    paused = !paused;
    pause.textContent = paused ? 'Resume animation' : 'Pause animation';
    pause.setAttribute('aria-pressed', paused);
};
compare.onclick = () => {
    steady = !steady;
    compare.textContent = steady ? 'Show startup' : 'Show steady title';
    compare.setAttribute('aria-pressed', steady);
};
document.getElementById('intensity').oninput = event => {
    intensity = event.target.value / 100;
    document.getElementById('value').value = event.target.value + '%';
};
document.getElementById('haloIntensity').oninput = event => {
    haloIntensity = event.target.value / 100;
    document.getElementById('haloValue').value = event.target.value + '%';
};
restart();
Promise.all(Array.from(document.images).map(image => image.decode()))
    .then(() => requestAnimationFrame(draw))
    .catch(() => { status.textContent = 'Could not load the preview images.'; });
