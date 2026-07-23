# Mikoto

[![CI](https://github.com/biyuehu/mikoto/actions/workflows/ci.yml/badge.svg)](https://github.com/biyuehu/mikoto/actions/workflows/ci.yml) ![License](https://img.shields.io/badge/License-GPL--3.0-blue?style=flat-square)

[👉 Demo 👈](https://mikoto-img.vercel.app/)

A simple abd tiny image encoding/decoding tool based on Teal. Powered by efficient algorithms, it is designed for evading network content censorship and surveillance. Supports web and cli tools.

## Arhitecture

**Teal Source Code** → **Cyan building tool: transform Teal to Lua** -> **Vite import Lua raw code when compiling** → **TypeScript execute Lua code by `lua-in-js` package** -> **Bun!**

## Usage

### WebSite

Click `Demo` link.

### Download

Download from [GitHub Action](https://github.com/biyuehu/mikoto/actions/workflows/ci.yml).

## Algorithm

The core image processing pipeline utilizes a **Linear Congruential Permutation** algorithm to map 2D image coordinates into a 1D space and apply lossless pixel scrambling.

### 1. Spatial Mapping

To convert between 2D pixel coordinates $(x, y)$ and a 1D flat index $i$ given image width $W$:

$$i = y \cdot W + x$$

$$\begin{cases} x = i \bmod W \\ y = \lfloor i / W \rfloor \end{cases}$$

### 2. Key Generation

For an image with total pixels $N = W \times H$, an initial scalar is derived using the golden ratio:

$$k_{\text{init}} = \lfloor N \times 0.6180339887 \rfloor$$

The key $k$ is adjusted until it satisfies coprimality with $N$:

$$\gcd(k, N) = 1 \quad \text{and} \quad k \notin \{1, N - 1\}$$

### 3. Encoding & Decoding

Pixel scrambling and reconstruction rely on modular arithmetic:

* **Encoding (Permutation)**:
  Maps the original pixel index $i$ to a new position $i'$:
  $$i' = (i \cdot k) \bmod N$$

* **Decoding (Restoration)**:
  Computes the modular multiplicative inverse $k^{-1}$ via the Extended Euclidean Algorithm:
  $$(k \cdot k^{-1}) \equiv 1 \pmod N$$
  Restores the original index $i$ using the inverse key:
  $$i = (i' \cdot k^{-1}) \bmod N$$

> **Performance Note**: Operates in $\mathcal{O}(N)$ time complexity with zero quality loss, effectively transforming structured image data into high-entropy visual noise.

## License

Under the GNU General Public License v3.0.
