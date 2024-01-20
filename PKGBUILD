# Maintainer: lilikoi <jamilbio20@gmail.com>
pkgname='chatgpt.sh-git'
_pkgname='chatgpt.sh'
pkgver=0.100.r3
pkgrel=1
pkgdesc='Shell wrapper for text and chat completions, DALL-E, Whisper, and awesome-chatgpt-prompts(-zh).'
url='https://gitlab.com/fenixdragao/shellchatgpt'
arch=('any')
license=('GPL3')
provides=('chatgpt.sh')
depends=('bash' 'curl' 'jq')
makedepends=('git')
optdepends=(
	'imagemagick: edit input images'
	'sox: audio recorder / player'
	'ffmpeg: audio recorder'
	'mpv: audio player'
	#'coreutils: wrap output at spaces (fold)'
	'xdg-utils: open images (xdg-open, open)'
	'xsel: copy output to clipboard'
	'xclip: copy output to clipboard'
	'python: count input tokens (tiktoken)'
)
source=("${pkgname}::git+${url}.git")
sha256sums=('SKIP')

pkgver() {
	cd "${pkgname}"
	printf "%s.r%s" "$(sed -n 's/-/./g;s/^# v\([0-9a-zA-Z.-]\+\) .*/\1/p' "${_pkgname}")" "$(git rev-parse --short=7 HEAD)"
}

package() {
	cd "${pkgname}"
	install -Dm644 "LICENSE" "$pkgdir/usr/share/licenses/${_pkgname}/LICENSE"
	install -Dm644 "man/${_pkgname}.1" "${pkgdir}/usr/share/man/man1/${_pkgname}.1"
	install -Dm644 "man/${_pkgname}.txt" "$pkgdir/usr/share/doc/${_pkgname}/${_pkgname}.txt"
	install -Dm644 "man/${_pkgname}.html" "$pkgdir/usr/share/doc/${_pkgname}/${_pkgname}.html"
	install -Dm644 "man/README.md" "$pkgdir/usr/share/doc/${_pkgname}/${_pkgname}.md"
	install -Dm644 "README.md" "$pkgdir/usr/share/doc/${_pkgname}/README.md"
	#install -Dm644 "PKGBUILD" "$pkgdir/usr/share/doc/${_pkgname}/PKGBUILD"
	install -Dm644 ".chatgpt.conf" "$pkgdir/usr/share/doc/${_pkgname}/chatgpt.conf"
	install -Dm755 "${_pkgname}" "${pkgdir}/usr/bin/${_pkgname}"
}
