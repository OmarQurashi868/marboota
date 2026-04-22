import { useEffect } from 'react'
import { DiscordSession, useDiscordSdk } from '../hooks/useDiscordSdk'
import { useGodot } from '../hooks/useGodot'
import { DiscordSDK, DiscordSDKMock } from '@discord/embedded-app-sdk'

declare global {
	interface Window {
		discord: {
			sdk: DiscordSDK | DiscordSDKMock
			accessToken: string | null
			session: DiscordSession | null
			status: 'authenticating' | 'error' | 'loading' | 'pending' | 'ready'
		}
	}
}

export const Activity = () => {
	const { discordSdk, status, accessToken, session } = useDiscordSdk()

	useEffect(() => {
		// pass discordSdk to window for use in Godot
		window.discord = {
			sdk: discordSdk,
			accessToken,
			session,
			status
		}

		console.log('set', window.discord)
	}, [discordSdk, status, accessToken, session])

	const { startGame, loading } = useGodot('/Game/marboota-game')
	let isStarted = false
	if (!loading && !isStarted) {
		startGame()
		isStarted = true
	}

	return (
		<div>
			{loading && <img src="/Logo.png" className="logo" alt="Logo" />}
			
			{loading && <h1>Marboota</h1>}

			{loading ? (
				<progress value={typeof loading === 'number' ? loading : undefined} max={100}></progress>
			) : (
				<div className="game">
					<canvas id="godot-canvas" tabIndex={-1} />
				</div>
			)}
			
			{loading && <br />}
			{loading && (
				<small>
					Powered by <strong>Robo.js</strong>
				</small>
			)}
		</div>
	)
}
