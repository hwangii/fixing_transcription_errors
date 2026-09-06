import os
from pytz import timezone
import logging
import requests
import json
import traceback
from datetime import datetime
import time
import threading

MAX_THREADS = 20
CENSUS_FOLDER_NAME = 'United States Census 1930'
LOCAL_IMAGES_FOLDER = 'F:/census1930_image_download_continued'

SCRIPT_TIMEZONE = timezone('America/Vancouver')
SCRIPT_DIR = os.path.realpath('.')
LOG_FILE_PATH = f"{SCRIPT_DIR}/Log.txt"
STOP_FLAG_FILE_PATH = f"{SCRIPT_DIR}/CONTINUE"
PROCESSED_COUNT = 0

SERVER_DOMAINS = None

class CustomFormatter(logging.Formatter):
	def format(self, record):
		base_fmt = "%(asctime)s.%(msecs)03d %(levelname)-8s"
		log_fmt = f"{base_fmt}{'' if record.levelno is logging.INFO else '(%(pathname)s:%(lineno)d)' + chr(10)}%(message)s"
		log_str = logging.Formatter(log_fmt, datefmt='%Y-%m-%d %H:%M:%S').format(record).replace("\n", f"\n{' '*32}")
		
		final_log_str = log_str if record.levelno is logging.INFO else f"\n{log_str}\n"

		return final_log_str

class MyJsonEncoder(json.JSONEncoder):
	
	def default(self, obj):
		
		try:
			return json.JSONEncoder.default(self, obj)
		except:

			if type(obj) is set:
				return [*obj]

			# obj is not JSON serializable

			print("\n\n\n\n\n\n")
			print(obj)
			print("\n\n\n\n\n\n")

			return repr(obj)

class CustomException(Exception):
	def __init__(self, message = None, debug_info = None, should_stop = False):
		Exception.__init__(self, message)
		# self.message = message
		self.debug_info = debug_info
		self.should_stop = should_stop

class KillThreadException(SystemExit):
	pass

class KillableThreadGroup():

	def __init__(self):
		self.threads = []
		self.has_error = False
		self.original_exception = None
		self.debug_info = []

	def append(self, thread):
		self.threads.append(thread)

	def thread_count(self):
		return len(self.threads)

	def kill(self, thread, killer_exception):
		
		self.has_error = True

		if not isinstance(killer_exception, BaseException):
			killer_exception = CustomException('"killer_exception" must derive from BaseException!', {
				'debug_info': repr(killer_exception),
			})

		if self.original_exception is None:
			self.original_exception = killer_exception
			
		self.debug_info.append({
			'index': thread.index,
			'name': thread.name,
			'debug_info': get_exception_info(killer_exception),
		})

class KillableThread(threading.Thread):

	def __init__(self, thread_group, kill_others, format_prefix = '', *args, **kwargs):
		
		kwargs['args'] = (self, *(kwargs['args'] if 'args' in kwargs else ()))
		
		threading.Thread.__init__(self, *args, daemon = True, **kwargs)

		self.kill_others = bool(kill_others)
		
		self.thread_group = thread_group
		
		self.format_prefix = format_prefix
		
		self.index = self.thread_group.thread_count()

		self.thread_group.append(self)
	
	def get_formatted_index(self, val = 'T'):
		return f"{self.format_prefix}{val} {self.index} / {len(self.thread_group.threads) - 1}"

	def start(self):
		self.__run_backup = self.run
		self.run = self.__run
		self._wait_for_tstate_lock = self._wait_for_tstate_lock_custom
		threading.Thread.start(self)
	
	def __run(self):

		try:
			self.__run_backup()
			self.run = self.__run_backup

		except KeyboardInterrupt as e:
			self.thread_group.kill(self, e)

		except KillThreadException:
			# this thread was killed by other
			pass

		except BaseException as e:
		
			if not self.kill_others:
				raise

			# mark thread group as killed
			self.thread_group.kill(self, e)

			# logger.info(get_exception_info(e))

	def _wait_for_tstate_lock_custom(self, block=True, timeout=-1):
		# Issue #18808: wait for the thread state to be gone.
		# At the end of the thread's life, after all knowledge of the thread
		# is removed from C data structures, C code releases our _tstate_lock.
		# This method passes its arguments to _tstate_lock.acquire().
		# If the lock is acquired, the C code is done, and self._stop() is
		# called.  That sets ._is_stopped to True, and ._tstate_lock to None.
		lock = self._tstate_lock
		if lock is None:  # already determined that the C code is done
			assert self._is_stopped
		else:
			while True:
				if lock.acquire(block, 0.1):
					lock.release()
					self._stop()
					break

	def join(self):

		try:
			threading.Thread.join(self)

		except KeyboardInterrupt as e:
		
			if not self.kill_others:
				raise
			
			# mark thread group as killed
			self.thread_group.kill(self, e)
	
	def stop_if_killed(self):
		if self.thread_group.has_error:
			raise KillThreadException()

def json_stringify(data, compact = True, pretty = None):

	if pretty is True:
		return json.dumps(data, indent = 4, ensure_ascii = False, cls = MyJsonEncoder)

	elif compact is True:
		return json.dumps(data, separators = (',', ':'), ensure_ascii = False, cls = MyJsonEncoder)

	else:
		return json.dumps(data, ensure_ascii = False, cls = MyJsonEncoder)

def get_exception_info(e):

	exception_info = {
		'class': e.__class__.__name__,
		'message': e.args[0] if len(e.args) > 0 else None,
		'traceback': ''.join(traceback.format_exception(None, e, e.__traceback__)),
		'debug_info': e.debug_info if hasattr(e, 'debug_info') else None,
	}

	return exception_info

def normalize_response(response):

	is_json = 'content-type' in response.headers and 'application/json' == response.headers['content-type']

	normalized_response =  {
		'ststus_code': response.status_code,
		'url': response.url,
		'headers': dict(response.headers),
		'text': response.text,
		'request': {
			'method': response.request.method,
			'url': response.request.url,
			'headers': dict(response.request.headers),
			'body': response.request.body,
		},
		'history': [*map(normalize_response, response.history)],
	}

	if is_json:
		try:
			normalized_response['json'] = response.json()
		except requests.exceptions.JSONDecodeError:
			pass

	return normalized_response

def sleep(s, thread = None):

	for _ in range(0, int(s * 100)):

		if thread is not None:
			thread.stop_if_killed()

		time.sleep(0.01)

def get_timestamp():
	return datetime.now(SCRIPT_TIMEZONE)

def print_stats():

	time_taken = (get_timestamp() - SCRIPT_START_TIMESTAMP).total_seconds()

	print('', flush = True)

	logger.info(f"Processed Things: {PROCESSED_COUNT}")
	logger.info(f"Time taken: {time_taken:.3f} seconds")

	avg_time = time_taken if 0 == PROCESSED_COUNT else (time_taken * 1000 / PROCESSED_COUNT)

	if PROCESSED_COUNT > 0:
		logger.info(f"Avg. time: {avg_time:.3f}s / 1000 Things")

def init():

	global logger, SCRIPT_START_TIMESTAMP

	SCRIPT_START_TIMESTAMP = get_timestamp()

	# create logger

	logging.raiseExceptions = False

	logger = logging.getLogger('CUSTOM')
	logger.setLevel(logging.DEBUG)
	logging.Formatter.converter = lambda *args: get_timestamp().timetuple()

	console = logging.StreamHandler()
	console.setLevel(logger.level)
	console.setFormatter(CustomFormatter())
	logger.addHandler(console)

	if LOG_FILE_PATH is not None:
		logfile = logging.FileHandler(LOG_FILE_PATH, 'a', encoding='utf-8-sig')
		logfile.setLevel(logger.level)
		logfile.setFormatter(CustomFormatter())
		logger.addHandler(logfile)

	# disable request verify
	requests.packages.urllib3.disable_warnings(requests.packages.urllib3.exceptions.InsecureRequestWarning)

def remove_stop_file():
	if os.path.isfile(STOP_FLAG_FILE_PATH):
		os.remove(STOP_FLAG_FILE_PATH)

def start():

	try:
		logger.info(f"Script {os.path.basename(__file__)} started..")
		transfer_images()

	except KeyboardInterrupt:
		# manual abort
		logger.info(f"Manual Abort!")

	except BaseException as e:
		logger.error(json_stringify(get_exception_info(e), pretty = True))
	
	finally:
		print_stats()
		remove_stop_file()
		logger.info(f"Script {os.path.basename(__file__)} complete.")

def stop_if_needed():

	if not os.path.isfile(STOP_FLAG_FILE_PATH):
		# should stop
		raise KeyboardInterrupt

def transfer_images():

	# touch STOP flag file
	with open(STOP_FLAG_FILE_PATH, 'w') as f:
		pass

	while True:

		images_to_download = load_images_to_transfer()

		stop_if_needed()

		load_domain_list_if_needed()

		if 0 == len(images_to_download):
			# there are no images remaining to transfer
			logger.info(f"No images available to transfer! Waiting for 10 minutes..")
			sleep(600)
			continue

		# start threads
		if True:

			threads_count__transfer_images = min(len(images_to_download), MAX_THREADS)

			logger.info(f"Transferring {len(images_to_download)} images ···· Starting {threads_count__transfer_images} threads..")

			thread_group__transfer_images = KillableThreadGroup()

			for thread_index in range(0, threads_count__transfer_images):

				thread = KillableThread(
					thread_group = thread_group__transfer_images,
					kill_others = True,
					format_prefix = 'T',
					target = threadfn__transfer_images,
					args = [images_to_download],
				)

			# start all threads
			for thread in thread_group__transfer_images.threads:
				thread.start()

			# wait for all threads to complete
			for thread in thread_group__transfer_images.threads:
				thread.join()

			print('\n', end = '', flush = True)

			if thread_group__transfer_images.has_error:
				raise thread_group__transfer_images.original_exception

			logger.info(f"Transferring images ···· Threads complete!")

			print_stats()

def load_images_to_transfer():

	logger.info(f"Loading list of images to transfer..")

	try_count = 0

	while True:

		try_count += 1

		stop_if_needed()

		try:

			url = 'https://jd.rankhub.in/get_download_list.php'

			response = requests.get(url = url, timeout = 100, verify = False)

			if 502 == response.status_code or 524 == response.status_code or 530 == response.status_code:
				# cloudflare gateway timeout
				logger.info(f"Gateway Timeout Error! Trying again after 60 seconds..")
				sleep(60)
				continue

			if 200 != response.status_code:
				raise CustomException(
					f"Unexpected HTTP Code {response.status_code} while loading list of images to transfer!",
					{
						'response': normalize_response(response),
					}
				)

			response_json = response.json()

			if 'error' in response_json or 'success' not in response_json or response_json['success'] is not True:
				raise CustomException(
					f"Unexpected error while loading list of images to transfer!",
					{
						'response': normalize_response(response),
					}
				)

			images_to_download = response_json['data']

			logger.info(f"A list of {len(images_to_download)} images loaded.")

			return images_to_download

		except KeyboardInterrupt:
			raise

		except BaseException as e:

			if 'ConnectionError' in repr(e):
				continue

			if 'ChunkedEncodingError' in repr(e):
				continue

			if 'ReadTimeout' in repr(e):
				continue

			if 'SSLError' in repr(e):
				continue

			if 'MaxRetryError' in repr(e):
				continue

			sleep(1)

			if try_count >= 5:
				raise

def load_domain_list_if_needed():

	global SERVER_DOMAINS

	if SERVER_DOMAINS is None:

		logger.info(f"Loading list of server domains..")

		try_count = 0

		while True:

			try_count += 1

			stop_if_needed()

			try:

				url = 'https://jd.rankhub.in/get_domain_list.php'

				response = requests.get(url = url, timeout = 100, verify = False)

				if 502 == response.status_code or 524 == response.status_code or 530 == response.status_code:
					# cloudflare gateway timeout
					logger.info(f"Gateway Timeout Error! Trying again after 60 seconds..")
					sleep(60)
					continue

				if 200 != response.status_code:
					raise CustomException(
						f"Unexpected HTTP Code {response.status_code} while loading list of server domains!",
						{
							'response': normalize_response(response),
						}
					)

				response_json = response.json()

				if 'error' in response_json or 'success' not in response_json or response_json['success'] is not True:
					raise CustomException(
						f"Unexpected error while loading list of server domains!",
						{
							'response': normalize_response(response),
						}
					)

				SERVER_DOMAINS = response_json['data']

				logger.info(f"A list of {len(SERVER_DOMAINS)} domains loaded.")

				return

			except KeyboardInterrupt:
				raise

			except BaseException as e:

				if 'ConnectionError' in repr(e):
					continue

				if 'ChunkedEncodingError' in repr(e):
					continue

				if 'ReadTimeout' in repr(e):
					continue

				if 'SSLError' in repr(e):
					continue

				if 'MaxRetryError' in repr(e):
					continue

				sleep(1)

				if try_count >= 5:
					raise

def download_image(thread, JD_ID, folder, ark_id):

	domain_index = thread.index % len(SERVER_DOMAINS)
	domain = SERVER_DOMAINS[domain_index]

	url = f"https://{domain}/{CENSUS_FOLDER_NAME}/{folder}/{ark_id}.jpg"

	try_count = 0

	while True:

		try_count += 1

		stop_if_needed()
		thread.stop_if_killed()

		try:

			# transfer image
			if True:

				response = requests.get(url = url, timeout = 100, verify = False)

				if 502 == response.status_code or 524 == response.status_code or 530 == response.status_code:
					# cloudflare gateway timeout
					sleep(min(try_count, 600), thread)
					continue

				if 200 != response.status_code:
					raise CustomException(
						f"Unexpected HTTP Code {response.status_code} while downloading image!",
						{
							'JD_ID': JD_ID,
							'folder': folder,
							'ark_id': ark_id,
							'response': normalize_response(response),
						}
					)

				if 'content-type' not in response.headers or 'image/jpeg' != response.headers['content-type']:
					raise CustomException(
						f"Unexpected response while downloading image!",
						{
							'JD_ID': JD_ID,
							'folder': folder,
							'ark_id': ark_id,
							'response': normalize_response(response),
						}
					)

			# write to local file
			if True:
				local_image_folder = f"{LOCAL_IMAGES_FOLDER}/{CENSUS_FOLDER_NAME}/{folder}"
				local_image_path = f"{local_image_folder}/{ark_id}.jpg"

				os.makedirs(local_image_folder, exist_ok = True)

				with open(local_image_path, 'wb') as image_file:
					for chunk in response:
						image_file.write(chunk)

			break

		except KeyboardInterrupt:
			raise

		except KillThreadException:
			raise

		except BaseException as e:
			if try_count >= 5:
				raise

def mark_images_as_transferred(thread, transferred_JD_IDs):

	url = 'https://jd.rankhub.in/mark_images_as_transferred.php'

	data = {
		'transferred_JD_IDs': transferred_JD_IDs,
	}

	try_count = 0

	while True:

		stop_if_needed()
		thread.stop_if_killed()

		try_count += 1

		try:

			response = requests.post(url = url, data = json_stringify(data), timeout = 100, verify = False)

			if 502 == response.status_code or 524 == response.status_code or 530 == response.status_code:
				# cloudflare gateway timeout
				sleep(min(try_count, 600), thread)
				continue

			if 200 != response.status_code:
				raise CustomException(
					f"Unexpected HTTP Code {response.status_code} while marking image as transferred!",
					{
						'transferred_JD_IDs': transferred_JD_IDs,
						'response': normalize_response(response),
					}
				)

			response_json = response.json()

			if 'error' in response_json or 'success' not in response_json or response_json['success'] is not True or response_json['data'] is not True:
				raise CustomException(
					f"Unexpected error while marking image as transferred!",
					{
						'transferred_JD_IDs': transferred_JD_IDs,
						'response': normalize_response(response),
					}
				)

			break

		except KeyboardInterrupt:
			raise

		except KillThreadException:
			raise

		except BaseException as e:
			if try_count >= 5:
				raise

def threadfn__transfer_images(thread, images_to_download):

	global PROCESSED_COUNT

	transferred_JD_IDs = []

	while len(images_to_download) > 0:

		stop_if_needed()

		try:
			image = images_to_download.pop(0)
		except IndexError:
			# in case of race condition where some other thread already "popped" the last available item
			return

		JD_ID, folder, ark_id = image

		try:

			thread.stop_if_killed()

			# mark it as transferred
			download_image(thread, JD_ID, folder, ark_id)

			# mark it as transferred
			if True:
				transferred_JD_IDs.append(JD_ID)

				if len(transferred_JD_IDs) >= 100:
					mark_images_as_transferred(thread, transferred_JD_IDs)
					transferred_JD_IDs = []

			PROCESSED_COUNT += 1

			if PROCESSED_COUNT > 0:

				if 0 == PROCESSED_COUNT % 1000:
					print(f"{int(PROCESSED_COUNT / 1000)}k", flush = True)
					print_stats()

				elif 0 == PROCESSED_COUNT % 100:
					print('#', flush = True)

				elif 0 == PROCESSED_COUNT % 1:
					print('.', end = '', flush = True)

		except KeyboardInterrupt:
			remove_stop_file()
			raise

		except KillThreadException:
			remove_stop_file()
			raise

		except BaseException as e:

			if 'ConnectionError' in repr(e):
				sleep(0.5, thread)
				images_to_download.insert(0, image)
				continue

			if 'ChunkedEncodingError' in repr(e):
				sleep(0.5, thread)
				images_to_download.insert(0, image)
				continue

			if 'ReadTimeout' in repr(e):
				sleep(0.5, thread)
				images_to_download.insert(0, image)
				continue

			if 'JSONDecodeError' in repr(e):
				sleep(0.5, thread)
				images_to_download.insert(0, image)
				continue

			if 'SSLError' in repr(e):
				sleep(0.5, thread)
				images_to_download.insert(0, image)
				continue

			if 'MaxRetryError' in repr(e):
				sleep(0.5, thread)
				images_to_download.insert(0, image)
				continue

			logger.error(f"[{thread.get_formatted_index()}] - (BaseException) JD_ID: {JD_ID} ···· ark_id: {ark_id}\n{repr(e)}")
			
			raise

	if len(transferred_JD_IDs) >= 0:
		mark_images_as_transferred(thread, transferred_JD_IDs)

if '__main__' == __name__:

	# create logger object
	init()

	start()
